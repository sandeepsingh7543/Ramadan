import SwiftUI
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins
import Vision

class PhotoEditorViewModel: ObservableObject {
    @Published var originalImage: UIImage
    @Published var currentImage: UIImage?
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var selectedFilter: FilterType = .original
    
    @Published var brightness: Double = 0
    @Published var contrast: Double = 1
    @Published var saturation: Double = 1
    @Published var exposure: Double = 0
    @Published var sharpness: Double = 0
    @Published var highlights: Double = 0
    @Published var shadows: Double = 0
    
    @Published var blurAmount: Double = 0
    @Published var vignetteAmount: Double = 0
    @Published var noiseReduction: Double = 0
    
    private var undoStack: [UIImage] = []
    private var redoStack: [UIImage] = []
    private let context = CIContext()
    private let maxUndoStackSize = 10
    
    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }
    
    init(image: UIImage) {
        self.originalImage = image
        self.currentImage = image
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.alertMessage = message
            self?.showAlert = true
            self?.isLoading = false
        }
    }
    
    func saveToUndo() {
        if let image = currentImage {
            undoStack.append(image)
            if undoStack.count > maxUndoStackSize {
                undoStack.removeFirst()
            }
            redoStack.removeAll()
        }
    }
    
    func undo() {
        guard let last = undoStack.popLast() else { return }
        if let current = currentImage {
            redoStack.append(current)
        }
        currentImage = last
    }
    
    func redo() {
        guard let last = redoStack.popLast() else { return }
        if let current = currentImage {
            undoStack.append(current)
        }
        currentImage = last
    }
    
    func resetAdjustments() {
        brightness = 0
        contrast = 1
        saturation = 1
        exposure = 0
        sharpness = 0
        highlights = 0
        shadows = 0
        blurAmount = 0
        vignetteAmount = 0
        noiseReduction = 0
        selectedFilter = .original
    }
    
    // MARK: - Background Removal (Vision Framework)
    
    func removeBackground() {
        guard let image = currentImage else {
            showError("No image available")
            return
        }
        saveToUndo()
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            guard let cgImage = image.cgImage else {
                self.showError("Failed to process image")
                return
            }
            
            let request = VNGeneratePersonSegmentationRequest()
            request.qualityLevel = .balanced
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
                
                guard let result = request.results?.first as? VNPixelBufferObservation else {
                    self.showError("Failed to detect background")
                    return
                }
                
                let mask = result.pixelBuffer
                let processedImage = self.applySegmentationMask(mask, to: image)
                
                DispatchQueue.main.async {
                    self.currentImage = processedImage
                    self.isLoading = false
                }
            } catch {
                self.showError("Background removal failed")
            }
        }
    }
    
    private func applySegmentationMask(_ mask: CVPixelBuffer, to image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        let width = CVPixelBufferGetWidth(mask)
        let height = CVPixelBufferGetHeight(mask)
        
        CVPixelBufferLockBaseAddress(mask, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(mask, .readOnly) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(mask) else { return image }
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(mask)
        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return image }
        
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        
        for y in 0..<height {
            for x in 0..<width {
                let maskValue = buffer[y * bytesPerRow + x]
                let alpha = UInt8(Float(maskValue) * 0.8)
                
                let pixelIndex = (y * width + x) * 4
                pixelData[pixelIndex] = 255
                pixelData[pixelIndex + 1] = 255
                pixelData[pixelIndex + 2] = 255
                pixelData[pixelIndex + 3] = alpha
            }
        }
        
        context.data?.copyMemory(from: &pixelData, byteCount: pixelData.count)
        
        guard let maskedCGImage = context.makeImage() else { return image }
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        guard let scaledCGImage = maskedCGImage.cropping(to: rect) else { return image }
        
        return UIImage(cgImage: scaledCGImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    // MARK: - Filters
    
    func applyFilter(_ type: FilterType) {
        guard let image = currentImage else {
            showError("No image available")
            return
        }
        saveToUndo()
        selectedFilter = type
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            guard let ciImage = CIImage(image: image) else {
                self.showError("Failed to process image")
                return
            }
            
            var outputImage: CIImage?
            
            switch type {
            case .original:
                outputImage = ciImage
            case .blackAndWhite:
                let filter = CIFilter.photoEffectNoir()
                filter.inputImage = ciImage
                outputImage = filter.outputImage
            case .vintage:
                let filter = CIFilter.sepiaTone()
                filter.inputImage = ciImage
                filter.intensity = 0.8
                outputImage = filter.outputImage
            case .cinematic:
                let filter = CIFilter.colorControls()
                filter.inputImage = ciImage
                filter.contrast = 1.4
                filter.saturation = 0.7
                outputImage = filter.outputImage
            case .warm:
                let filter = CIFilter.colorControls()
                filter.inputImage = ciImage
                filter.brightness = 0.1
                outputImage = filter.outputImage
            case .cool:
                let filter = CIFilter.colorControls()
                filter.inputImage = ciImage
                filter.brightness = -0.1
                outputImage = filter.outputImage
            case .sepia:
                let filter = CIFilter.sepiaTone()
                filter.inputImage = ciImage
                filter.intensity = 1.0
                outputImage = filter.outputImage
            case .vivid:
                let filter = CIFilter.colorControls()
                filter.inputImage = ciImage
                filter.saturation = 1.5
                filter.contrast = 1.2
                outputImage = filter.outputImage
            }
            
            if let output = outputImage,
               let cgImage = self.context.createCGImage(output, from: output.extent) {
                DispatchQueue.main.async {
                    self.currentImage = UIImage(cgImage: cgImage)
                    self.isLoading = false
                }
            } else {
                self.showError("Failed to apply filter")
            }
        }
    }
    
    // MARK: - Adjustments
    
    func applyAdjustments() {
        guard let ciImage = CIImage(image: originalImage) else { return }
        
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.brightness = Float(brightness)
        filter.contrast = Float(contrast)
        filter.saturation = Float(saturation)
        
        if let output = filter.outputImage,
           let cgImage = context.createCGImage(output, from: output.extent) {
            currentImage = UIImage(cgImage: cgImage)
        }
    }
    
    // MARK: - Effects
    
    func applyBlur() {
        guard let image = currentImage else { return }
        saveToUndo()
        
        guard let ciImage = CIImage(image: image) else { return }
        
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = ciImage
        filter.radius = Float(blurAmount)
        
        if let output = filter.outputImage,
           let cgImage = context.createCGImage(output, from: ciImage.extent) {
            currentImage = UIImage(cgImage: cgImage)
        }
    }
    
    func applyVignette() {
        guard let image = currentImage else { return }
        saveToUndo()
        
        guard let ciImage = CIImage(image: image) else { return }
        
        let filter = CIFilter.vignette()
        filter.inputImage = ciImage
        filter.intensity = Float(vignetteAmount)
        
        if let output = filter.outputImage,
           let cgImage = context.createCGImage(output, from: output.extent) {
            currentImage = UIImage(cgImage: cgImage)
        }
    }
    
    func applyNoiseReduction() {
        guard let image = currentImage else { return }
        saveToUndo()
        
        guard let ciImage = CIImage(image: image) else { return }
        
        let filter = CIFilter.noiseReduction()
        filter.inputImage = ciImage
        
        if let output = filter.outputImage,
           let cgImage = context.createCGImage(output, from: output.extent) {
            currentImage = UIImage(cgImage: cgImage)
        }
    }
    
    // MARK: - Transform
    
    func rotateImage() {
        guard let image = currentImage else { return }
        saveToUndo()
        
        guard let cgImage = image.cgImage else { return }
        let rotated = UIImage(cgImage: cgImage, scale: image.scale, orientation: .right)
        currentImage = rotated
    }
    
    func flipHorizontal() {
        guard let image = currentImage else { return }
        saveToUndo()
        
        guard let cgImage = image.cgImage else { return }
        currentImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .upMirrored)
    }
    
    func flipVertical() {
        guard let image = currentImage else { return }
        saveToUndo()
        
        guard let cgImage = image.cgImage else { return }
        currentImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .downMirrored)
    }
    
    func setCropRatio(_ ratio: CGFloat) {
        // Crop implementation ready for extension
    }
    
    // MARK: - Save
    
    func saveToLibrary() {
        guard let image = currentImage else {
            DispatchQueue.main.async { [weak self] in
                self?.alertMessage = "No image to save"
                self?.showAlert = true
            }
            return
        }
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            
            switch status {
            case .authorized, .limited:
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            self.alertMessage = "Photo saved successfully!"
                            self.showAlert = true
                        } else {
                            let errorMsg = error?.localizedDescription ?? "Unknown error"
                            self.alertMessage = "Failed to save: \(errorMsg)"
                            self.showAlert = true
                        }
                    }
                }
                
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.alertMessage = "Photo library access denied. Enable in Settings > Privacy > Photos."
                    self.showAlert = true
                }
                
            case .notDetermined:
                DispatchQueue.main.async {
                    self.alertMessage = "Please grant photo library access."
                    self.showAlert = true
                }
                
            @unknown default:
                DispatchQueue.main.async {
                    self.alertMessage = "Unable to access photo library."
                    self.showAlert = true
                }
            }
        }
    }
}

enum FilterType: Equatable {
    case original, blackAndWhite, vintage, cinematic, warm, cool, sepia, vivid
}
