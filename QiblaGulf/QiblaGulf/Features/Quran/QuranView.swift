import SwiftUI

struct QuranView: View {
    @State private var searchText = ""
    @State private var selectedSurah: Surah?
    
    let surahs = QuranData.allSurahs
    
    var filteredSurahs: [Surah] {
        if searchText.isEmpty {
            return surahs
        }
        return surahs.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.englishName.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Surah List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredSurahs) { surah in
                            NavigationLink(destination: SurahDetailView(surah: surah)) {
                                SurahRow(surah: surah)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("Holy Quran")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.theme.textSecondary)
            
            TextField("Search Surah", text: $text)
                .foregroundColor(Color.theme.textPrimary)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.theme.textSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.theme.cardBackground)
        .cornerRadius(12)
    }
}

struct SurahRow: View {
    let surah: Surah
    
    var body: some View {
        HStack(spacing: 16) {
            // Number Badge
            ZStack {
                Circle()
                    .stroke(Color.theme.primary, lineWidth: 2)
                    .frame(width: 45, height: 45)
                
                Text("\(surah.id)")
                    .font(.headline)
                    .foregroundColor(Color.theme.primary)
            }
            
            // Surah Info
            VStack(alignment: .leading, spacing: 4) {
                Text(surah.englishName)
                    .font(.headline)
                    .foregroundColor(Color.theme.textPrimary)
                
                Text("\(surah.revelationType) • \(surah.numberOfVerses) verses")
                    .font(.caption)
                    .foregroundColor(Color.theme.textSecondary)
            }
            
            Spacer()
            
            // Arabic Name
            Text(surah.arabicName)
                .font(.title3)
                .foregroundColor(Color.theme.primary)
        }
        .padding()
        .cardStyle()
    }
}

struct SurahDetailView: View {
    let surah: Surah
    var verses: [QuranVerse] {
        QuranData.allVerses.filter { $0.surahNumber == surah.id }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Surah Header
                VStack(spacing: 12) {
                    Text(surah.arabicName)
                        .font(.system(size: 36))
                        .foregroundColor(Color.theme.primary)
                    
                    Text(surah.englishName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text("\(surah.revelationType) • \(surah.numberOfVerses) Verses")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .cardStyle()
                
                // Bismillah (except Surah 9)
                if surah.id != 9 {
                    Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                        .font(.title)
                        .foregroundColor(Color.theme.primary)
                        .padding()
                        .cardStyle()
                }
                
                // Verses
                ForEach(verses) { verse in
                    VerseCard(verse: verse)  // VerseCard ko verse object pass karna
                }
            }
            .padding()
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct VerseCard: View {
//    let verseNumber: Int
    let verse: QuranVerse  // verseNumber nahi, pura verse object

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            // Verse Number Badge
            HStack {
                Spacer()
                Text("\(verse.verseNumber)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.theme.primary)
                    .clipShape(Circle())
            }
            
            // Arabic Text
            Text(verse.arabicText)
                .font(.system(size: 24))
                .foregroundColor(Color.theme.textPrimary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Divider()
            
            // Translation
            Text(verse.translation)
                .font(.body)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .cardStyle()
    }
}

// Sample Data
struct QuranData {
    static let allSurahs: [Surah] = [
        Surah(id: 1, name: "Al-Fatihah", arabicName: "الفاتحة", englishName: "The Opening", numberOfVerses: 7, revelationType: "Meccan"),
//        Surah(id: 2, name: "Al-Baqarah", arabicName: "البقرة", englishName: "The Cow", numberOfVerses: 286, revelationType: "Medinan"),
        Surah(id: 3, name: "Aal-E-Imran", arabicName: "آل عمران", englishName: "Family of Imran", numberOfVerses: 200, revelationType: "Medinan"),
        Surah(id: 4, name: "An-Nisa", arabicName: "النساء", englishName: "The Women", numberOfVerses: 176, revelationType: "Medinan"),
        Surah(id: 5, name: "Al-Ma'idah", arabicName: "المائدة", englishName: "The Table", numberOfVerses: 120, revelationType: "Medinan"),
        Surah(id: 6, name: "Al-An'am", arabicName: "الأنعام", englishName: "The Cattle", numberOfVerses: 165, revelationType: "Meccan"),
        Surah(id: 7, name: "Al-A'raf", arabicName: "الأعراف", englishName: "The Heights", numberOfVerses: 206, revelationType: "Meccan"),
        Surah(id: 8, name: "Al-Anfal", arabicName: "الأنفال", englishName: "The Spoils of War", numberOfVerses: 75, revelationType: "Medinan"),
        Surah(id: 9, name: "At-Tawbah", arabicName: "التوبة", englishName: "The Repentance", numberOfVerses: 129, revelationType: "Medinan"),
        Surah(id: 10, name: "Yunus", arabicName: "يونس", englishName: "Jonah", numberOfVerses: 109, revelationType: "Meccan"),
        Surah(id: 11, name: "Hud", arabicName: "هود", englishName: "Hud", numberOfVerses: 123, revelationType: "Meccan"),
        Surah(id: 12, name: "Yusuf", arabicName: "يوسف", englishName: "Joseph", numberOfVerses: 111, revelationType: "Meccan"),
        Surah(id: 13, name: "Ar-Ra'd", arabicName: "الرعد", englishName: "The Thunder", numberOfVerses: 43, revelationType: "Medinan"),
        Surah(id: 14, name: "Ibrahim", arabicName: "إبراهيم", englishName: "Abraham", numberOfVerses: 52, revelationType: "Meccan"),
        Surah(id: 15, name: "Al-Hijr", arabicName: "الحجر", englishName: "The Rocky Tract", numberOfVerses: 99, revelationType: "Meccan"),
        Surah(id: 16, name: "An-Nahl", arabicName: "النحل", englishName: "The Bee", numberOfVerses: 128, revelationType: "Meccan"),
        Surah(id: 17, name: "Al-Isra", arabicName: "الإسراء", englishName: "The Night Journey", numberOfVerses: 111, revelationType: "Meccan"),
        Surah(id: 18, name: "Al-Kahf", arabicName: "الكهف", englishName: "The Cave", numberOfVerses: 110, revelationType: "Meccan"),
        Surah(id: 19, name: "Maryam", arabicName: "مريم", englishName: "Mary", numberOfVerses: 98, revelationType: "Meccan"),
        Surah(id: 20, name: "Ta-Ha", arabicName: "طه", englishName: "Ta-Ha", numberOfVerses: 135, revelationType: "Meccan"),
        Surah(id: 21, name: "Al-Anbiya", arabicName: "الأنبياء", englishName: "The Prophets", numberOfVerses: 112, revelationType: "Meccan"),
        Surah(id: 22, name: "Al-Hajj", arabicName: "الحج", englishName: "The Pilgrimage", numberOfVerses: 78, revelationType: "Medinan"),
        Surah(id: 23, name: "Al-Mu'minun", arabicName: "المؤمنون", englishName: "The Believers", numberOfVerses: 118, revelationType: "Meccan"),
        Surah(id: 24, name: "An-Nur", arabicName: "النور", englishName: "The Light", numberOfVerses: 64, revelationType: "Medinan"),
        Surah(id: 25, name: "Al-Furqan", arabicName: "الفرقان", englishName: "The Criterion", numberOfVerses: 77, revelationType: "Meccan"),
        Surah(id: 26, name: "Ash-Shu'ara", arabicName: "الشعراء", englishName: "The Poets", numberOfVerses: 227, revelationType: "Meccan"),
        Surah(id: 27, name: "An-Naml", arabicName: "النمل", englishName: "The Ant", numberOfVerses: 93, revelationType: "Meccan"),
        Surah(id: 28, name: "Al-Qasas", arabicName: "القصص", englishName: "The Stories", numberOfVerses: 88, revelationType: "Meccan"),
        Surah(id: 29, name: "Al-Ankabut", arabicName: "العنكبوت", englishName: "The Spider", numberOfVerses: 69, revelationType: "Meccan"),
        Surah(id: 30, name: "Ar-Rum", arabicName: "الروم", englishName: "The Romans", numberOfVerses: 60, revelationType: "Meccan"),
        Surah(id: 31, name: "Luqman", arabicName: "لقمان", englishName: "Luqman", numberOfVerses: 34, revelationType: "Meccan"),
        Surah(id: 32, name: "As-Sajdah", arabicName: "السجدة", englishName: "The Prostration", numberOfVerses: 30, revelationType: "Meccan"),
        Surah(id: 33, name: "Al-Ahzab", arabicName: "الأحزاب", englishName: "The Confederates", numberOfVerses: 73, revelationType: "Medinan"),
        Surah(id: 34, name: "Saba", arabicName: "سبأ", englishName: "Sheba", numberOfVerses: 54, revelationType: "Meccan"),
        Surah(id: 35, name: "Fatir", arabicName: "فاطر", englishName: "The Originator", numberOfVerses: 45, revelationType: "Meccan"),
        Surah(id: 36, name: "Ya-Sin", arabicName: "يس", englishName: "Ya-Sin", numberOfVerses: 83, revelationType: "Meccan"),
        Surah(id: 37, name: "As-Saffat", arabicName: "الصافات", englishName: "Those who set the Ranks", numberOfVerses: 182, revelationType: "Meccan"),
        Surah(id: 38, name: "Sad", arabicName: "ص", englishName: "Sad", numberOfVerses: 88, revelationType: "Meccan"),
        Surah(id: 39, name: "Az-Zumar", arabicName: "الزمر", englishName: "The Groups", numberOfVerses: 75, revelationType: "Meccan"),
        Surah(id: 40, name: "Ghafir", arabicName: "غافر", englishName: "The Forgiver", numberOfVerses: 85, revelationType: "Meccan"),
        Surah(id: 41, name: "Fussilat", arabicName: "فصلت", englishName: "Explained in Detail", numberOfVerses: 54, revelationType: "Meccan"),
        Surah(id: 42, name: "Ash-Shura", arabicName: "الشورى", englishName: "The Consultation", numberOfVerses: 53, revelationType: "Meccan"),
        Surah(id: 43, name: "Az-Zukhruf", arabicName: "الزخرف", englishName: "Gold Adornments", numberOfVerses: 89, revelationType: "Meccan"),
        Surah(id: 44, name: "Ad-Dukhan", arabicName: "الدخان", englishName: "The Smoke", numberOfVerses: 59, revelationType: "Meccan"),
        Surah(id: 45, name: "Al-Jathiyah", arabicName: "الجاثية", englishName: "The Crouching", numberOfVerses: 37, revelationType: "Meccan"),
        Surah(id: 46, name: "Al-Ahqaf", arabicName: "الأحقاف", englishName: "The Wind-Curved Sandhills", numberOfVerses: 35, revelationType: "Meccan"),
        Surah(id: 47, name: "Muhammad", arabicName: "محمد", englishName: "Muhammad", numberOfVerses: 38, revelationType: "Medinan"),
        Surah(id: 48, name: "Al-Fath", arabicName: "الفتح", englishName: "The Victory", numberOfVerses: 29, revelationType: "Medinan"),
        Surah(id: 49, name: "Al-Hujurat", arabicName: "الحجرات", englishName: "The Rooms", numberOfVerses: 18, revelationType: "Medinan"),
        Surah(id: 50, name: "Qaf", arabicName: "ق", englishName: "Qaf", numberOfVerses: 45, revelationType: "Meccan"),
        Surah(id: 51, name: "Adh-Dhariyat", arabicName: "الذاريات", englishName: "The Winnowing Winds", numberOfVerses: 60, revelationType: "Meccan"),
        Surah(id: 52, name: "At-Tur", arabicName: "الطور", englishName: "The Mount", numberOfVerses: 49, revelationType: "Meccan"),
        Surah(id: 53, name: "An-Najm", arabicName: "النجم", englishName: "The Star", numberOfVerses: 62, revelationType: "Meccan"),
        Surah(id: 54, name: "Al-Qamar", arabicName: "القمر", englishName: "The Moon", numberOfVerses: 55, revelationType: "Meccan"),
        Surah(id: 55, name: "Ar-Rahman", arabicName: "الرحمن", englishName: "The Beneficent", numberOfVerses: 78, revelationType: "Medinan"),
        Surah(id: 56, name: "Al-Waqiah", arabicName: "الواقعة", englishName: "The Inevitable", numberOfVerses: 96, revelationType: "Meccan"),
        Surah(id: 57, name: "Al-Hadid", arabicName: "الحديد", englishName: "The Iron", numberOfVerses: 29, revelationType: "Medinan"),
        Surah(id: 58, name: "Al-Mujadila", arabicName: "المجادلة", englishName: "The Pleading Woman", numberOfVerses: 22, revelationType: "Medinan"),
        Surah(id: 59, name: "Al-Hashr", arabicName: "الحشر", englishName: "The Exile", numberOfVerses: 24, revelationType: "Medinan"),
        Surah(id: 60, name: "Al-Mumtahina", arabicName: "الممتحنة", englishName: "She that is to be examined", numberOfVerses: 13, revelationType: "Medinan"),
        Surah(id: 61, name: "As-Saff", arabicName: "الصف", englishName: "The Ranks", numberOfVerses: 14, revelationType: "Medinan"),
        Surah(id: 62, name: "Al-Jumu'ah", arabicName: "الجمعة", englishName: "The Congregation, Friday", numberOfVerses: 11, revelationType: "Medinan"),
        Surah(id: 63, name: "Al-Munafiqun", arabicName: "المنافقون", englishName: "The Hypocrites", numberOfVerses: 11, revelationType: "Medinan"),
        Surah(id: 64, name: "At-Taghabun", arabicName: "التغابن", englishName: "Mutual Disillusion", numberOfVerses: 18, revelationType: "Medinan"),
        Surah(id: 65, name: "At-Talaq", arabicName: "الطلاق", englishName: "Divorce", numberOfVerses: 12, revelationType: "Medinan"),
        Surah(id: 66, name: "At-Tahrim", arabicName: "التحريم", englishName: "Prohibition", numberOfVerses: 12, revelationType: "Medinan"),
        Surah(id: 67, name: "Al-Mulk", arabicName: "الملك", englishName: "The Sovereignty", numberOfVerses: 30, revelationType: "Meccan"),
        Surah(id: 68, name: "Al-Qalam", arabicName: "القلم", englishName: "The Pen", numberOfVerses: 52, revelationType: "Meccan"),
        Surah(id: 69, name: "Al-Haqqa", arabicName: "الحاقة", englishName: "The Reality", numberOfVerses: 52, revelationType: "Meccan"),
        Surah(id: 70, name: "Al-Ma'arij", arabicName: "المعارج", englishName: "The Ascending Stairways", numberOfVerses: 44, revelationType: "Meccan"),
        Surah(id: 71, name: "Nuh", arabicName: "نوح", englishName: "Noah", numberOfVerses: 28, revelationType: "Meccan"),
        Surah(id: 72, name: "Al-Jinn", arabicName: "الجن", englishName: "The Jinn", numberOfVerses: 28, revelationType: "Meccan"),
        Surah(id: 73, name: "Al-Muzzammil", arabicName: "المزمل", englishName: "The Enshrouded One", numberOfVerses: 20, revelationType: "Meccan"),
        Surah(id: 74, name: "Al-Muddaththir", arabicName: "المدثر", englishName: "The Cloaked One", numberOfVerses: 56, revelationType: "Meccan"),
        Surah(id: 75, name: "Al-Qiyamah", arabicName: "القيامة", englishName: "The Resurrection", numberOfVerses: 40, revelationType: "Meccan"),
        Surah(id: 76, name: "Al-Insan", arabicName: "الانسان", englishName: "Man", numberOfVerses: 31, revelationType: "Medinan"),
        Surah(id: 77, name: "Al-Mursalat", arabicName: "المرسلات", englishName: "The Emissaries", numberOfVerses: 50, revelationType: "Meccan"),
        Surah(id: 78, name: "An-Naba", arabicName: "النبأ", englishName: "The Tidings", numberOfVerses: 40, revelationType: "Meccan"),
        Surah(id: 79, name: "An-Nazi'at", arabicName: "النازعات", englishName: "Those Who Drag Forth", numberOfVerses: 46, revelationType: "Meccan"),
        Surah(id: 80, name: "Abasa", arabicName: "عبس", englishName: "He Frowned", numberOfVerses: 42, revelationType: "Meccan"),
        Surah(id: 81, name: "At-Takwir", arabicName: "التكوير", englishName: "The Overthrowing", numberOfVerses: 29, revelationType: "Meccan"),
        Surah(id: 82, name: "Al-Infitar", arabicName: "الانفطار", englishName: "The Cleaving", numberOfVerses: 19, revelationType: "Meccan"),
        Surah(id: 83, name: "Al-Mutaffifin", arabicName: "المطففين", englishName: "Defrauding", numberOfVerses: 36, revelationType: "Meccan"),
        Surah(id: 84, name: "Al-Inshiqaq", arabicName: "الانشقاق", englishName: "The Splitting Open", numberOfVerses: 25, revelationType: "Meccan"),
        Surah(id: 85, name: "Al-Buruj", arabicName: "البروج", englishName: "The Mansions of the Stars", numberOfVerses: 22, revelationType: "Meccan"),
        Surah(id: 86, name: "At-Tariq", arabicName: "الطارق", englishName: "The Morning Star", numberOfVerses: 17, revelationType: "Meccan"),
        Surah(id: 87, name: "Al-A'la", arabicName: "الأعلى", englishName: "The Most High", numberOfVerses: 19, revelationType: "Meccan"),
        Surah(id: 88, name: "Al-Ghashiyah", arabicName: "الغاشية", englishName: "The Overwhelming", numberOfVerses: 26, revelationType: "Meccan"),
        Surah(id: 89, name: "Al-Fajr", arabicName: "الفجر", englishName: "The Dawn", numberOfVerses: 30, revelationType: "Meccan"),
        Surah(id: 90, name: "Al-Balad", arabicName: "البلد", englishName: "The City", numberOfVerses: 20, revelationType: "Meccan"),
        Surah(id: 91, name: "Ash-Shams", arabicName: "الشمس", englishName: "The Sun", numberOfVerses: 15, revelationType: "Meccan"),
        Surah(id: 92, name: "Al-Lail", arabicName: "الليل", englishName: "The Night", numberOfVerses: 21, revelationType: "Meccan"),
        Surah(id: 93, name: "Ad-Duha", arabicName: "الضحى", englishName: "The Morning Hours", numberOfVerses: 11, revelationType: "Meccan"),
        Surah(id: 94, name: "Ash-Sharh", arabicName: "الشرح", englishName: "The Relief", numberOfVerses: 8, revelationType: "Meccan"),
        Surah(id: 95, name: "At-Tin", arabicName: "التين", englishName: "The Fig", numberOfVerses: 8, revelationType: "Meccan"),
        Surah(id: 96, name: "Al-Alaq", arabicName: "العلق", englishName: "The Clot", numberOfVerses: 19, revelationType: "Meccan"),
        Surah(id: 97, name: "Al-Qadr", arabicName: "القدر", englishName: "The Power", numberOfVerses: 5, revelationType: "Meccan"),
        Surah(id: 98, name: "Al-Bayyinah", arabicName: "البينة", englishName: "The Clear Proof", numberOfVerses: 8, revelationType: "Medinan"),
        Surah(id: 99, name: "Az-Zalzalah", arabicName: "الزلزلة", englishName: "The Earthquake", numberOfVerses: 8, revelationType: "Medinan"),
        Surah(id: 100, name: "Al-Adiyat", arabicName: "العاديات", englishName: "The Courser", numberOfVerses: 11, revelationType: "Meccan"),
        Surah(id: 101, name: "Al-Qari'ah", arabicName: "القارعة", englishName: "The Calamity", numberOfVerses: 11, revelationType: "Meccan"),
        Surah(id: 102, name: "At-Takathur", arabicName: "التكاثر", englishName: "Rivalry in world increase", numberOfVerses: 8, revelationType: "Meccan"),
        Surah(id: 103, name: "Al-Asr", arabicName: "العصر", englishName: "Time", numberOfVerses: 3, revelationType: "Meccan"),
        Surah(id: 104, name: "Al-Humazah", arabicName: "الهمزة", englishName: "The Slanderer", numberOfVerses: 9, revelationType: "Meccan"),
        Surah(id: 105, name: "Al-Fil", arabicName: "الفيل", englishName: "The Elephant", numberOfVerses: 5, revelationType: "Meccan"),
        Surah(id: 106, name: "Quraysh", arabicName: "قريش", englishName: "Quraysh", numberOfVerses: 4, revelationType: "Meccan"),
        Surah(id: 107, name: "Al-Ma'un", arabicName: "الماعون", englishName: "Small Kindnesses", numberOfVerses: 7, revelationType: "Meccan"),
        Surah(id: 108, name: "Al-Kawthar", arabicName: "الكوثر", englishName: "Abundance", numberOfVerses: 3, revelationType: "Meccan"),
        Surah(id: 109, name: "Al-Kafirun", arabicName: "الكافرون", englishName: "The Disbelievers", numberOfVerses: 6, revelationType: "Meccan"),
        Surah(id: 110, name: "An-Nasr", arabicName: "النصر", englishName: "Divine Support", numberOfVerses: 3, revelationType: "Medinan"),
        Surah(id: 111, name: "Al-Masad", arabicName: "المسد", englishName: "The Palm Fiber", numberOfVerses: 5, revelationType: "Meccan"),
        Surah(id: 112, name: "Al-Ikhlas", arabicName: "الإخلاص", englishName: "Sincerity", numberOfVerses: 4, revelationType: "Meccan"),
        Surah(id: 113, name: "Al-Falaq", arabicName: "الفلق", englishName: "The Daybreak", numberOfVerses: 5, revelationType: "Meccan"),
        Surah(id: 114, name: "An-Nas", arabicName: "الناس", englishName: "Mankind", numberOfVerses: 6, revelationType: "Meccan")
    ]
    static let allVerses: [QuranVerse] = [
        // Surah 1 – Al-Fatihah
        QuranVerse(surahNumber: 1, verseNumber: 1, arabicText: "بسم الله الرحمن الرحيم", translation: "In the name of Allah, the Most Gracious, the Most Merciful", transliteration: "Bismillah ir-Rahman ir-Rahim"),
        QuranVerse(surahNumber: 1, verseNumber: 2, arabicText: "الحمد لله رب العالمين", translation: "All praise is due to Allah, Lord of the worlds", transliteration: "Alhamdulillahi Rabbil 'Alamin"),
        QuranVerse(surahNumber: 1, verseNumber: 3, arabicText: "الرحمن الرحيم", translation: "The Most Gracious, the Most Merciful", transliteration: "Ar-Rahman ir-Rahim"),
        QuranVerse(surahNumber: 1, verseNumber: 4, arabicText: "مالك يوم الدين", translation: "Master of the Day of Judgment", transliteration: "Maliki Yawmid-Din"),
        QuranVerse(surahNumber: 1, verseNumber: 5, arabicText: "إياك نعبد وإياك نستعين", translation: "You alone we worship, and You alone we ask for help", transliteration: "Iyyaka Na'budu wa iyyaka Nasta'in"),
        QuranVerse(surahNumber: 1, verseNumber: 6, arabicText: "اهدنا الصراط المستقيم", translation: "Guide us to the straight path", transliteration: "Ihdinas-Sirat al-Mustaqim"),
        QuranVerse(surahNumber: 1, verseNumber: 7, arabicText: "صراط الذين أنعمت عليهم غير المغضوب عليهم ولا الضالين", translation: "The path of those upon whom You have bestowed favor, not of those who have evoked Your anger or of those who are astray", transliteration: "Sirat alladhina an'amta 'alayhim ghayril-maghdoobi 'alayhim wa lad-dallin"),
        
        // Surah 3 – Aal-E-Imran
        QuranVerse(surahNumber: 3, verseNumber: 1, arabicText: "الم", translation: "Alif-Lam-Meem", transliteration: "Alif Lam Meem"),
        QuranVerse(surahNumber: 3, verseNumber: 2, arabicText: "اللّه لا إله إلا هو الحي القيوم", translation: "Allah! There is no deity except Him, the Ever-Living, the Sustainer", transliteration: "Allah la ilaha illa Huwa Al-Hayyul-Qayyum"),
        QuranVerse(surahNumber: 3, verseNumber: 3, arabicText: "أنزل عليك الكتاب بالحق", translation: "He has sent down upon you the Book with truth", transliteration: "Anzala 'alayka al-kitab bil-haqq"),
        QuranVerse(surahNumber: 3, verseNumber: 4, arabicText: "هدى للمتقين", translation: "Guidance for the righteous", transliteration: "Huda lil-muttaqin"),
        
        // Surah 4 – An-Nisa
        QuranVerse(surahNumber: 4, verseNumber: 1, arabicText: "يا أيها الناس اتقوا ربكم الذي خلقكم من نفس واحدة", translation: "O mankind, fear your Lord, who created you from one soul", transliteration: "Ya ayyuha an-nasu ittaqu rabbakumu allathee khalaqakum min nafsin wahidah"),
        QuranVerse(surahNumber: 4, verseNumber: 2, arabicText: "واتقوا الله الذي تساءلون به والأرحام", translation: "And fear Allah through whom you ask one another, and the wombs", transliteration: "Wa ittaqu Allaha allathee tasa'aloon bihi wal-arham"),
        QuranVerse(surahNumber: 4, verseNumber: 3, arabicText: "وأحسنوا إليهم كما أحسن إليكم", translation: "And treat them with kindness as He treated you", transliteration: "Wa ahsinoo ilayhim kama ahsana ilaykum"),
        QuranVerse(surahNumber: 4, verseNumber: 4, arabicText: "وأقيموا الصلاة وآتوا الزكاة", translation: "And establish prayer and give zakah", transliteration: "Wa aqeemoo as-salata wa aatuz-zakah"),
        
        // Surah 5 – Al-Ma'idah
        QuranVerse(surahNumber: 5, verseNumber: 1, arabicText: "يا أيها الذين آمنوا أوفوا بالعقود", translation: "O you who believe, fulfill all contracts", transliteration: "Ya ayyuha alladhina amanu awfu bil-'uqud"),
        QuranVerse(surahNumber: 5, verseNumber: 2, arabicText: "لا تنهوا عن الطيبات ما أحل الله لكم", translation: "Do not forbid the good things Allah has made lawful for you", transliteration: "La tanhuw 'an at-tayyibat ma ahalla Allahu lakum"),
        QuranVerse(surahNumber: 5, verseNumber: 3, arabicText: "وأطيعوا الله ورسوله", translation: "And obey Allah and His Messenger", transliteration: "Wa ati'oo Allaha wa Rasoolahu"),
        QuranVerse(surahNumber: 5, verseNumber: 4, arabicText: "ولا تأكلوا أموالكم بينكم بالباطل", translation: "And do not consume one another’s wealth unjustly", transliteration: "Wa la ta'kuloo amwalakum baynakum bil-batil"),
        
        // Surah 6 – Al-An'am
        QuranVerse(surahNumber: 6, verseNumber: 1, arabicText: "الْحَمْدُ لِلَّهِ الَّذِي خَلَقَ السَّمَاوَاتِ وَالأَرْضَ", translation: "All praise is due to Allah, who created the heavens and the earth", transliteration: "Alhamdulillahi allathee khalaqa as-samawati wal-ard"),
        QuranVerse(surahNumber: 6, verseNumber: 2, arabicText: "وَجَعَلَ الظُّلُمَاتِ وَالنُّورَ", translation: "And made the darkness and the light", transliteration: "Wa ja'ala az-zulumat wan-noor"),
        QuranVerse(surahNumber: 6, verseNumber: 3, arabicText: "وَهُوَ الَّذِي خَلَقَكُمْ", translation: "And He it is who created you", transliteration: "Wa huwa allathee khalaqakum"),
        QuranVerse(surahNumber: 6, verseNumber: 4, arabicText: "وَيَقُولُ أَنْ لَكُمْ", translation: "And He speaks and commands you", transliteration: "Wa yaqulu an lakum"),
        
        // Surah 7 – Al-A'raf
        QuranVerse(surahNumber: 7, verseNumber: 1, arabicText: "المص", translation: "Alif-Lam-Mim-Sad", transliteration: "Alif Lam Mim Sad"),
        QuranVerse(surahNumber: 7, verseNumber: 2, arabicText: "كَتَبْنَا عَلَى أَنَّهُمْ", translation: "We have decreed upon them", transliteration: "Katabna 'ala annahum"),
        QuranVerse(surahNumber: 7, verseNumber: 3, arabicText: "وَلَقَدْ أَرْسَلْنَا", translation: "And indeed We sent", transliteration: "Walaqad arsala"),
        QuranVerse(surahNumber: 7, verseNumber: 4, arabicText: "وَفَصَّلْنَا لَهُمْ", translation: "And We detailed for them", transliteration: "Wa fassalna lahum"),
        
        // Surah 8 – Al-Anfal
        QuranVerse(surahNumber: 8, verseNumber: 1, arabicText: "يَسْأَلُونَكَ عَنِ الْأَنْفَالِ", translation: "They ask you about the spoils of war", transliteration: "Yas'aloonaka 'anil-anfal"),
        QuranVerse(surahNumber: 8, verseNumber: 2, arabicText: "قُلِ الْأَنْفَالُ لِلَّهِ", translation: "Say, the spoils are for Allah", transliteration: "Qulil-anfalu lillah"),
        QuranVerse(surahNumber: 8, verseNumber: 3, arabicText: "وَأَطِيعُوا اللَّهَ وَرَسُولَهُ", translation: "And obey Allah and His Messenger", transliteration: "Wa ati'oo Allaha wa Rasoolahu"),
        QuranVerse(surahNumber: 8, verseNumber: 4, arabicText: "وَإِيَّاكُمْ أَنْ تُخْطِئُوا", translation: "And beware lest you err", transliteration: "Wa iyyakum an tukhtoo"),
        
        // Surah 9 – At-Tawbah
        QuranVerse(surahNumber: 9, verseNumber: 1, arabicText: "بَرَاءَةٌ مِنَ اللَّهِ وَرَسُولِهِ", translation: "A declaration of disassociation from Allah and His Messenger", transliteration: "Bara'atun min Allahi wa Rasoolihi"),
        QuranVerse(surahNumber: 9, verseNumber: 2, arabicText: "إِلَى الَّذِينَ عَاهَدتُّمْ", translation: "To those with whom you made a treaty", transliteration: "Ila alladhina 'ahadttum"),
        QuranVerse(surahNumber: 9, verseNumber: 3, arabicText: "فَسِيحُوا فِي الْأَرْضِ", translation: "So travel through the land freely", transliteration: "Fasihu fil-ard"),
        QuranVerse(surahNumber: 9, verseNumber: 4, arabicText: "وَاعْلَمُوا أَنَّ اللَّهَ", translation: "And know that Allah", transliteration: "Wa 'alamoo anna Allah"),
        
        // Surah 10 – Yunus
        QuranVerse(surahNumber: 10, verseNumber: 1, arabicText: "الر", translation: "Alif-Ra", transliteration: "Alif Ra"),
        QuranVerse(surahNumber: 10, verseNumber: 2, arabicText: "أَرْسَلْنَا الْكِتَابَ", translation: "We sent the Book", transliteration: "Arsalna al-kitab"),
        QuranVerse(surahNumber: 10, verseNumber: 3, arabicText: "لِيَكُونَ لِلْعَالَمِينَ", translation: "That it may be for the worlds", transliteration: "Li yakuna lil-'alameen"),
        QuranVerse(surahNumber: 10, verseNumber: 4, arabicText: "وَهُوَ الْحَقُّ", translation: "And it is the truth", transliteration: "Wa huwa al-haqq"),
        
        // Surah 11 – Hud
        QuranVerse(surahNumber: 11, verseNumber: 1, arabicText: "الر", translation: "Alif-Ra", transliteration: "Alif Ra"),
        QuranVerse(surahNumber: 11, verseNumber: 2, arabicText: "كَتَبَ اللهُ", translation: "Allah has decreed", transliteration: "Kataba Allahu"),
        QuranVerse(surahNumber: 11, verseNumber: 3, arabicText: "أَنْ لَا تَشْرِكُوا", translation: "That you do not associate partners with Him", transliteration: "An la tushriku"),
        QuranVerse(surahNumber: 11, verseNumber: 4, arabicText: "وَأَقِيمُوا الصَّلَاةَ", translation: "And establish prayer", transliteration: "Wa aqeemoo as-salata"),

        // Surah 12 – Yusuf
        QuranVerse(surahNumber: 12, verseNumber: 1, arabicText: "الر", translation: "Alif-Ra", transliteration: "Alif Ra"),
        QuranVerse(surahNumber: 12, verseNumber: 2, arabicText: "تِلْكَ آيَاتُ الْكِتَابِ", translation: "These are the verses of the Book", transliteration: "Tilka ayatul kitabi"),
        QuranVerse(surahNumber: 12, verseNumber: 3, arabicText: "قُصَصًا لِلنَّاسِ", translation: "A story for the people", transliteration: "Qasasaan lin-nas"),
        QuranVerse(surahNumber: 12, verseNumber: 4, arabicText: "وَنُورًا وَهُدًى", translation: "And guidance and light", transliteration: "Wa nooran wa hudan"),

        // Surah 13 – Ar-Ra’d
        QuranVerse(surahNumber: 13, verseNumber: 1, arabicText: "المر", translation: "Alif-Lam-Mim-Ra", transliteration: "Alif Lam Mim Ra"),
        QuranVerse(surahNumber: 13, verseNumber: 2, arabicText: "اللّهُ الّذِي يَسْمَعُ", translation: "Allah is the One who hears", transliteration: "Allahu allathee yasma'u"),
        QuranVerse(surahNumber: 13, verseNumber: 3, arabicText: "وَهُوَ عَلَى كُلِّ شَيْءٍ", translation: "And He is over all things", transliteration: "Wa huwa 'ala kulli shay'in"),
        QuranVerse(surahNumber: 13, verseNumber: 4, arabicText: "قَدِيرٌ", translation: "All-Powerful", transliteration: "Qadeerun"),

        // Surah 14 – Ibrahim
        QuranVerse(surahNumber: 14, verseNumber: 1, arabicText: "الر", translation: "Alif-Ra", transliteration: "Alif Ra"),
        QuranVerse(surahNumber: 14, verseNumber: 2, arabicText: "تِلْكَ آيَاتُ الْكِتَابِ", translation: "These are the verses of the Book", transliteration: "Tilka ayatul kitabi"),
        QuranVerse(surahNumber: 14, verseNumber: 3, arabicText: "هُدًى وَرَحْمَةً", translation: "Guidance and mercy", transliteration: "Hudan wa rahmatan"),
        QuranVerse(surahNumber: 14, verseNumber: 4, arabicText: "لِلْمُؤْمِنِينَ", translation: "For the believers", transliteration: "Lil-mu'mineen"),

        // Surah 15 – Al-Hijr
        QuranVerse(surahNumber: 15, verseNumber: 1, arabicText: "الر", translation: "Alif-Ra", transliteration: "Alif Ra"),
        QuranVerse(surahNumber: 15, verseNumber: 2, arabicText: "كِتَابٌ أُنزِلَ", translation: "A Book sent down", transliteration: "Kitabun unzila"),
        QuranVerse(surahNumber: 15, verseNumber: 3, arabicText: "مُبَارَكٌ", translation: "Blessed", transliteration: "Mubarakun"),
        QuranVerse(surahNumber: 15, verseNumber: 4, arabicText: "لِيَذَّكَّرَ", translation: "So that they may take heed", transliteration: "Li yazzakara"),

        // Surah 16 – An-Nahl
        QuranVerse(surahNumber: 16, verseNumber: 1, arabicText: "ألم", translation: "Alif-Lam-Mim", transliteration: "Alif Lam Mim"),
        QuranVerse(surahNumber: 16, verseNumber: 2, arabicText: "خَلَقَ اللَّهُ السَّمَاوَاتِ", translation: "Allah created the heavens", transliteration: "Khalaqa Allahu as-samawati"),
        QuranVerse(surahNumber: 16, verseNumber: 3, arabicText: "وَالْأَرْضَ", translation: "And the earth", transliteration: "Wal-ard"),
        QuranVerse(surahNumber: 16, verseNumber: 4, arabicText: "لِيَعْلَمَ أَنَّهُ", translation: "So that He may make known", transliteration: "Li ya'lama annahu"),

        // Surah 17 – Al-Isra
        QuranVerse(surahNumber: 17, verseNumber: 1, arabicText: "سُبْحَانَ الَّذِي أَسْرَى", translation: "Glory be to Him Who took", transliteration: "Subhana allathee asra"),
        QuranVerse(surahNumber: 17, verseNumber: 2, arabicText: "بِعَبْدِهِ", translation: "His servant", transliteration: "Bi'abdihi"),
        QuranVerse(surahNumber: 17, verseNumber: 3, arabicText: "لَيْلًا", translation: "By night", transliteration: "Laylan"),
        QuranVerse(surahNumber: 17, verseNumber: 4, arabicText: "مِنَ الْمَسْجِدِ الْحَرَامِ", translation: "From the Sacred Mosque", transliteration: "Min al-Masjidil-Haram"),

        // Surah 18 – Al-Kahf
        QuranVerse(surahNumber: 18, verseNumber: 1, arabicText: "الْحَمْدُ لِلَّهِ", translation: "All praise is for Allah", transliteration: "Alhamdulillahi"),
        QuranVerse(surahNumber: 18, verseNumber: 2, arabicText: "الَّذِي أَنْزَلَ عَلَى عَبْدِهِ", translation: "Who sent down upon His servant", transliteration: "Allathee anzala 'ala 'abdihi"),
        QuranVerse(surahNumber: 18, verseNumber: 3, arabicText: "الْكِتَابَ وَلَمْ", translation: "The Book, and did not make", transliteration: "Alkitaba walam"),
        QuranVerse(surahNumber: 18, verseNumber: 4, arabicText: "لَهُ عِوَجًا", translation: "There is any crookedness in it", transliteration: "Lahu 'iwajan"),

        // Surah 19 – Maryam
        QuranVerse(surahNumber: 19, verseNumber: 1, arabicText: "كهيعص", translation: "Kaf-Ha-Ya-Ain-Sad", transliteration: "Kaf Ha Ya Ain Sad"),
        QuranVerse(surahNumber: 19, verseNumber: 2, arabicText: "ذِكْرُ رَحْمَةٍ", translation: "A mention of mercy", transliteration: "Dhikru rahmatin"),
        QuranVerse(surahNumber: 19, verseNumber: 3, arabicText: "مِنْ رَبِّكَ", translation: "From your Lord", transliteration: "Min rabbika"),
        QuranVerse(surahNumber: 19, verseNumber: 4, arabicText: "لِلْمُؤْمِنِينَ", translation: "For the believers", transliteration: "Lil-mu'mineen"),

        // Surah 20 – Ta-Ha
        QuranVerse(surahNumber: 20, verseNumber: 1, arabicText: "طه", translation: "Ta-Ha", transliteration: "Ta-Ha"),
        QuranVerse(surahNumber: 20, verseNumber: 2, arabicText: "مَا أَنْزَلْنَا عَلَيْكَ", translation: "We have not sent down upon you", transliteration: "Ma anzalna 'alayka"),
        QuranVerse(surahNumber: 20, verseNumber: 3, arabicText: "الْقُرْآنَ لِتَشْقَى", translation: "The Quran that you may be distressed", transliteration: "Al-Qur'ana l-tashqa"),
        QuranVerse(surahNumber: 20, verseNumber: 4, arabicText: "إِلَّا تَذْكِرَةً", translation: "But as a reminder", transliteration: "Illa tadhkiratan"),
        
        // Surah 21 – Al-Anbiya
        QuranVerse(surahNumber: 21, verseNumber: 1, arabicText: "الْحَمْدُ لِلَّهِ الَّذِي خَلَقَ السَّمَاوَاتِ وَالأَرْضَ", translation: "Praise be to Allah who created the heavens and the earth", transliteration: "Alhamdulillahi allathee khalaqa as-samawati wal-ard"),
        QuranVerse(surahNumber: 21, verseNumber: 2, arabicText: "جَعَلَ لَكُمُ الأَرْضَ مِهَادًا", translation: "He made the earth a resting place for you", transliteration: "Ja'ala lakumu al-arda mihadan"),
        QuranVerse(surahNumber: 21, verseNumber: 3, arabicText: "وَالسَّمَاءَ بِنَاءً", translation: "And the sky a canopy", transliteration: "Was-samaa bina'an"),
        QuranVerse(surahNumber: 21, verseNumber: 4, arabicText: "وَأَنْزَلَ مِنَ السَّمَاءِ مَاءً", translation: "And sent down water from the sky", transliteration: "Wa anzala min as-samaa ma'an"),

        // Surah 22 – Al-Hajj
        QuranVerse(surahNumber: 22, verseNumber: 1, arabicText: "يَا أَيُّهَا النَّاسُ اتَّقُوا رَبَّكُمْ", translation: "O mankind, fear your Lord", transliteration: "Ya ayyuha an-nasu ittaqu rabbakum"),
        QuranVerse(surahNumber: 22, verseNumber: 2, arabicText: "الَّذِي خَلَقَكُمْ مِنْ نَفْسٍ وَاحِدَةٍ", translation: "Who created you from a single soul", transliteration: "Allathee khalaqakum min nafsin wahida"),
        QuranVerse(surahNumber: 22, verseNumber: 3, arabicText: "وَجَعَلَ مِنْهَا زَوْجَهَا", translation: "And created from it its mate", transliteration: "Wa ja'ala minha zawjaha"),
        QuranVerse(surahNumber: 22, verseNumber: 4, arabicText: "وَأَنْشَأَ مِنْهُمَا رِجَالًا كَثِيرًا", translation: "And spread from them many men and women", transliteration: "Wa ansha'a minhuma rijalan katheeran"),

        // Surah 23 – Al-Mu’minun
        QuranVerse(surahNumber: 23, verseNumber: 1, arabicText: "قَدْ أَفْلَحَ الْمُؤْمِنُونَ", translation: "Certainly will the believers have succeeded", transliteration: "Qad aflaha al-mu'minun"),
        QuranVerse(surahNumber: 23, verseNumber: 2, arabicText: "الَّذِينَ هُمْ فِي صَلَاتِهِمْ خَاشِعُونَ", translation: "Those who humble themselves in their prayers", transliteration: "Alladhina hum fi salatihim khashi'un"),
        QuranVerse(surahNumber: 23, verseNumber: 3, arabicText: "وَالَّذِينَ هُمْ عَنِ اللَّغْوِ مُعْرِضُونَ", translation: "And who avoid vain talk", transliteration: "Walladhina hum 'anil-laghwi mu'ridun"),
        QuranVerse(surahNumber: 23, verseNumber: 4, arabicText: "وَالَّذِينَ هُمْ لِلزَّكَاةِ فَاعِلُونَ", translation: "And those who give zakah", transliteration: "Walladhina hum lil-zakati fa'ilun"),

        // Surah 24 – An-Nur
        QuranVerse(surahNumber: 24, verseNumber: 1, arabicText: "سُورَةٌ أَنْزَلْنَاهَا وَفَرَضْنَاهَا", translation: "A chapter We have sent down and made obligatory", transliteration: "Suratun anzalnaha wa fardnaha"),
        QuranVerse(surahNumber: 24, verseNumber: 2, arabicText: "وَيَأْمُرُ بِالْمَعْرُوفِ", translation: "And enjoins what is right", transliteration: "Wa yamuru bil-ma'ruf"),
        QuranVerse(surahNumber: 24, verseNumber: 3, arabicText: "وَيَنْهَى عَنِ الْمُنْكَرِ", translation: "And forbids what is wrong", transliteration: "Wa yanha 'anil-munkar"),
        QuranVerse(surahNumber: 24, verseNumber: 4, arabicText: "وَيُحَذِّرُ الْمُؤْمِنِينَ", translation: "And warns the believers", transliteration: "Wa yuhadhirul-mu'mineen"),

        // Surah 25 – Al-Furqan
        QuranVerse(surahNumber: 25, verseNumber: 1, arabicText: "تَبَارَكَ الَّذِي نَزَّلَ الْفُرْقَانَ", translation: "Blessed is He who sent down the criterion (Al-Furqan)", transliteration: "Tabarakalladhi nazzalal-Furqan"),
        QuranVerse(surahNumber: 25, verseNumber: 2, arabicText: "عَلَى عَبْدِهِ لِيَكُونَ لِلْعَالَمِينَ", translation: "Upon His servant, that it may be for the worlds", transliteration: "Ala 'abdihi li yakuna lil-'alameen"),
        QuranVerse(surahNumber: 25, verseNumber: 3, arabicText: "وَهُدًى وَرَحْمَةً", translation: "And a guidance and mercy", transliteration: "Wa hudan wa rahmatan"),
        QuranVerse(surahNumber: 25, verseNumber: 4, arabicText: "لِلْمُؤْمِنِينَ", translation: "For the believers", transliteration: "Lil-mu'mineen"),

        // Surah 26 – Ash-Shu’ara
        QuranVerse(surahNumber: 26, verseNumber: 1, arabicText: "طسم", translation: "Ta-Sin-Mim", transliteration: "Ta Sin Mim"),
        QuranVerse(surahNumber: 26, verseNumber: 2, arabicText: "تِلْكَ آيَاتُ الْكِتَابِ", translation: "These are the verses of the Book", transliteration: "Tilka ayatul kitabi"),
        QuranVerse(surahNumber: 26, verseNumber: 3, arabicText: "وَهُدًى لِلْمُتَّقِينَ", translation: "And guidance for the righteous", transliteration: "Wa hudan lil-muttaqin"),
        QuranVerse(surahNumber: 26, verseNumber: 4, arabicText: "وَلَا يَزِدِ الظَّالِمِينَ", translation: "And it does not increase the wrongdoers except in loss", transliteration: "Wa la yazidil-zalimeena illa khasara"),

        // Surah 27 – An-Naml
        QuranVerse(surahNumber: 27, verseNumber: 1, arabicText: "طس", translation: "Ta-Seen", transliteration: "Ta Seen"),
        QuranVerse(surahNumber: 27, verseNumber: 2, arabicText: "تِلْكَ آيَاتُ الْقُرْآنِ", translation: "These are the verses of the Qur'an", transliteration: "Tilka ayatul Qur'an"),
        QuranVerse(surahNumber: 27, verseNumber: 3, arabicText: "وَهُدًى وَبَشِيرًا", translation: "And guidance and good tidings", transliteration: "Wa hudan wa basheeran"),
        QuranVerse(surahNumber: 27, verseNumber: 4, arabicText: "لِلْمُؤْمِنِينَ", translation: "For the believers", transliteration: "Lil-mu'mineen"),

        // Surah 28 – Al-Qasas
        QuranVerse(surahNumber: 28, verseNumber: 1, arabicText: "طسم", translation: "Ta-Sin-Mim", transliteration: "Ta Sin Mim"),
        QuranVerse(surahNumber: 28, verseNumber: 2, arabicText: "تِلْكَ آيَاتُ الْقُرْآنِ", translation: "These are the verses of the Qur'an", transliteration: "Tilka ayatul Qur'an"),
        QuranVerse(surahNumber: 28, verseNumber: 3, arabicText: "وَلَقَدْ أَرْسَلْنَا", translation: "And indeed We sent", transliteration: "Walaqad arsala"),
        QuranVerse(surahNumber: 28, verseNumber: 4, arabicText: "مُوسَىٰ بِآيَاتِنَا", translation: "Moses with Our signs", transliteration: "Musa bi ayatina"),

        // Surah 29 – Al-Ankabut
        QuranVerse(surahNumber: 29, verseNumber: 1, arabicText: "الم", translation: "Alif-Lam-Mim", transliteration: "Alif Lam Mim"),
        QuranVerse(surahNumber: 29, verseNumber: 2, arabicText: "أَحَسِبَ النَّاسُ", translation: "Do the people think", transliteration: "Ahsubu an-nasu"),
        QuranVerse(surahNumber: 29, verseNumber: 3, arabicText: "أَن يُتْرَكُوا", translation: "That they will be left alone", transliteration: "An yutrakoo"),
        QuranVerse(surahNumber: 29, verseNumber: 4, arabicText: "يَا أَيُّهَا النَّاسُ", translation: "O mankind", transliteration: "Ya ayyuha an-nasu"),

        // Surah 30 – Ar-Rum
        QuranVerse(surahNumber: 30, verseNumber: 1, arabicText: "الم", translation: "Alif-Lam-Mim", transliteration: "Alif Lam Mim"),
        QuranVerse(surahNumber: 30, verseNumber: 2, arabicText: "غُلِبَتِ الرُّومُ", translation: "The Romans have been defeated", transliteration: "Ghulibatir-Rum"),
        QuranVerse(surahNumber: 30, verseNumber: 3, arabicText: "فِي أَدْنَى الْأَرْضِ", translation: "In the nearest land", transliteration: "Fi adna al-ard"),
        QuranVerse(surahNumber: 30, verseNumber: 4, arabicText: "وَهُم مِّن بَعْدِ غَلَبِهِمْ", translation: "But they, after their defeat, will overcome", transliteration: "Wa hum min ba'di ghalabihim"),
        
        // Surah 31 – Luqman
        QuranVerse(surahNumber: 31, verseNumber: 1, arabicText: "الم", translation: "Alif-Lam-Mim", transliteration: "Alif Lam Mim"),
        QuranVerse(surahNumber: 31, verseNumber: 2, arabicText: "تِلْكَ آيَاتُ الْحِكْمَةِ", translation: "These are the verses of wisdom", transliteration: "Tilka ayatul hikmah"),
        QuranVerse(surahNumber: 31, verseNumber: 3, arabicText: "وَلِلْمُتَّقِينَ", translation: "For the righteous", transliteration: "Walil-muttaqin"),
        QuranVerse(surahNumber: 31, verseNumber: 4, arabicText: "نَصِيحَةً وَهُدًى", translation: "Advice and guidance", transliteration: "Nasihatan wa hudan"),

        // Surah 32 – As-Sajda
        QuranVerse(surahNumber: 32, verseNumber: 1, arabicText: "الم", translation: "Alif-Lam-Mim", transliteration: "Alif Lam Mim"),
        QuranVerse(surahNumber: 32, verseNumber: 2, arabicText: "تَنزِيلٌ مِنَ الرَّحْمَٰنِ الرَّحِيمِ", translation: "A revelation from the Most Merciful, the Most Compassionate", transliteration: "Tanzeelun mir-Rahmanir-Raheem"),
        QuranVerse(surahNumber: 32, verseNumber: 3, arabicText: "تَنزِيلُ الْكِتَابِ", translation: "Sent down the Book", transliteration: "Tanzeelu al-kitab"),
        QuranVerse(surahNumber: 32, verseNumber: 4, arabicText: "لِيَهْتَدُوا", translation: "So that they may be guided", transliteration: "Liyahtadu"),

        // Surah 33 – Al-Ahzab
        QuranVerse(surahNumber: 33, verseNumber: 1, arabicText: "يَا أَيُّهَا النَّبِيُّ اتَّقِ اللَّهَ", translation: "O Prophet, fear Allah", transliteration: "Ya ayyuha an-nabiyyu ittaqi Allah"),
        QuranVerse(surahNumber: 33, verseNumber: 2, arabicText: "وَلاَ تُطِعِ الْكَافِرِينَ", translation: "And do not obey the disbelievers", transliteration: "Wa la tuti al-kafireen"),
        QuranVerse(surahNumber: 33, verseNumber: 3, arabicText: "وَأَطِعِ اللَّهَ", translation: "And obey Allah", transliteration: "Wa ati Allah"),
        QuranVerse(surahNumber: 33, verseNumber: 4, arabicText: "وَرَسُولَهُ", translation: "And His Messenger", transliteration: "Wa Rasoolahu"),

        // Surah 34 – Saba
        QuranVerse(surahNumber: 34, verseNumber: 1, arabicText: "الْحَمْدُ لِلَّهِ", translation: "All praise is due to Allah", transliteration: "Alhamdulillahi"),
        QuranVerse(surahNumber: 34, verseNumber: 2, arabicText: "الَّذِي يَسْمَعُ الدُّعَاءَ", translation: "Who hears the supplication", transliteration: "Allathee yasma'u ad-dua"),
        QuranVerse(surahNumber: 34, verseNumber: 3, arabicText: "وَهُوَ الْقَرِيبُ", translation: "And He is near", transliteration: "Wa huwa al-qareeb"),
        QuranVerse(surahNumber: 34, verseNumber: 4, arabicText: "مُجِيبٌ لِلْمُسْتَغِيثِينَ", translation: "Responds to those who call upon Him", transliteration: "Mujeebul-mustagheesin"),

        // Surah 35 – Fatir
        QuranVerse(surahNumber: 35, verseNumber: 1, arabicText: "الْحَمْدُ لِلَّهِ فَاطِرِ السَّمَاوَاتِ وَالأَرْضِ", translation: "Praise be to Allah, Originator of the heavens and the earth", transliteration: "Alhamdulillahi Fatiris-Samawati wal-Ard"),
        QuranVerse(surahNumber: 35, verseNumber: 2, arabicText: "جَاعِلِ الْمَلَائِكَةِ رُسُلًا", translation: "He made the angels messengers", transliteration: "Ja'ilil-malaikati rusulan"),
        QuranVerse(surahNumber: 35, verseNumber: 3, arabicText: "ذِينَ لَهُمْ أَجْنِحَةٌ", translation: "With wings", transliteration: "Alladhina lahum ajniha"),
        QuranVerse(surahNumber: 35, verseNumber: 4, arabicText: "مَثْنًى وَثُلَاثًا وَرُبَاعًا", translation: "Two, three, or four", transliteration: "Mathnan wa thalathan wa rubaa"),

        // Surah 36 – Ya-Sin
        QuranVerse(surahNumber: 36, verseNumber: 1, arabicText: "يس", translation: "Ya-Sin", transliteration: "Ya Sin"),
        QuranVerse(surahNumber: 36, verseNumber: 2, arabicText: "وَالْقُرْآنِ الْحَكِيمِ", translation: "By the wise Qur'an", transliteration: "Wal-Qur'ani Al-Hakeem"),
        QuranVerse(surahNumber: 36, verseNumber: 3, arabicText: "إِنَّكَ لَمِنَ الْمُرْسَلِينَ", translation: "Indeed you are among the messengers", transliteration: "Innak laminal-mursaleen"),
        QuranVerse(surahNumber: 36, verseNumber: 4, arabicText: "عَلَى صِرَاطٍ مُسْتَقِيمٍ", translation: "On a straight path", transliteration: "Ala siratin mustaqeem"),

        // Surah 37 – As-Saffat
        QuranVerse(surahNumber: 37, verseNumber: 1, arabicText: "وَالْمُرْسَلِينَ", translation: "By those sent forth", transliteration: "Wal-mursaleen"),
        QuranVerse(surahNumber: 37, verseNumber: 2, arabicText: "الْمُقَتَّنِينَ", translation: "Who drive with determination", transliteration: "Al-muqattaneen"),
        QuranVerse(surahNumber: 37, verseNumber: 3, arabicText: "فِي صُفُوفٍ", translation: "In ranks", transliteration: "Fi sufuf"),
        QuranVerse(surahNumber: 37, verseNumber: 4, arabicText: "يَبْسُطُونَ", translation: "Stretch forth", transliteration: "Yabsutoon"),

        // Surah 38 – Sad
        QuranVerse(surahNumber: 38, verseNumber: 1, arabicText: "ص", translation: "Sad", transliteration: "Sad"),
        QuranVerse(surahNumber: 38, verseNumber: 2, arabicText: "وَالْقُرْآنِ الْمَجِيدِ", translation: "By the glorious Qur'an", transliteration: "Wal-Qur'ani Al-Majeed"),
        QuranVerse(surahNumber: 38, verseNumber: 3, arabicText: "إِنَّكَ لَمِنَ الْمُرْسَلِينَ", translation: "Indeed you are among the messengers", transliteration: "Innak laminal-mursaleen"),
        QuranVerse(surahNumber: 38, verseNumber: 4, arabicText: "إِلَى صِرَاطٍ مُسْتَقِيمٍ", translation: "On a straight path", transliteration: "Ila siratin mustaqeem"),

        // Surah 39 – Az-Zumar
        QuranVerse(surahNumber: 39, verseNumber: 1, arabicText: "الْحَمْدُ لِلَّهِ", translation: "All praise is due to Allah", transliteration: "Alhamdulillahi"),
        QuranVerse(surahNumber: 39, verseNumber: 2, arabicText: "وَالَّذِي أَنْزَلَ الْكِتَابَ", translation: "And who sent down the Book", transliteration: "Wallathee anzala al-kitab"),
        QuranVerse(surahNumber: 39, verseNumber: 3, arabicText: "إِنَّ اللَّهَ عَزِيزٌ حَكِيمٌ", translation: "Indeed Allah is Exalted in Might and Wise", transliteration: "Inna Allaha Azizun Hakeem"),
        QuranVerse(surahNumber: 39, verseNumber: 4, arabicText: "يَقُومُ بِالْأَمْرِ", translation: "He manages the affairs", transliteration: "Yaqoomu bil-amr"),

        // Surah 40 – Ghafir
        QuranVerse(surahNumber: 40, verseNumber: 1, arabicText: "حَم", translation: "Ha-Mim", transliteration: "Ha Mim"),
        QuranVerse(surahNumber: 40, verseNumber: 2, arabicText: "تَنزِيلٌ مِنَ الرَّحْمَٰنِ الرَّحِيمِ", translation: "A revelation from the Most Merciful, the Most Compassionate", transliteration: "Tanzeelun mir-Rahmanir-Raheem"),
        QuranVerse(surahNumber: 40, verseNumber: 3, arabicText: "لِيَهْتَدُوا إِلَى الْحَقِّ", translation: "So that they may be guided to the truth", transliteration: "Liyahtadu ila al-haqq"),
        QuranVerse(surahNumber: 40, verseNumber: 4, arabicText: "وَلِيُذْكَرُوا", translation: "And so that they may remember", transliteration: "Wa li yudhkaru"),
        
        // Surah 41 – Fussilat
        QuranVerse(surahNumber: 41, verseNumber: 1, arabicText: "حم", translation: "Ha-Mim", transliteration: "Ha Mim"),
        QuranVerse(surahNumber: 41, verseNumber: 2, arabicText: "تَنزِيلٌ مِنَ الرَّحْمَٰنِ الرَّحِيمِ", translation: "A revelation from the Most Merciful, the Most Compassionate", transliteration: "Tanzeelun mir-Rahmanir-Raheem"),
        QuranVerse(surahNumber: 41, verseNumber: 3, arabicText: "كِتَابٌ فُصِّلَتْ آيَاتُهُ", translation: "A Book whose verses have been detailed", transliteration: "Kitabun fussilat ayatuhu"),
        QuranVerse(surahNumber: 41, verseNumber: 4, arabicText: "لِقَوْمٍ يَعْلَمُونَ", translation: "For a people who know", transliteration: "Liqawmin ya'lamoon"),

        // Surah 42 – Ash-Shura
        QuranVerse(surahNumber: 42, verseNumber: 1, arabicText: "حم عسق", translation: "Ha-Mim-Ain-Sin-Qaf", transliteration: "Ha Mim 'Ain Sin Qaf"),
        QuranVerse(surahNumber: 42, verseNumber: 2, arabicText: "تَنزِيلٌ مِنَ الرَّحْمَٰنِ الرَّحِيمِ", translation: "A revelation from the Most Merciful, the Most Compassionate", transliteration: "Tanzeelun mir-Rahmanir-Raheem"),
        QuranVerse(surahNumber: 42, verseNumber: 3, arabicText: "كِتَابٌ فَصَّلْنَاهُ لِلْقَوْمِ", translation: "A book We have detailed for the people", transliteration: "Kitabun fassalnahu lilqawm"),
        QuranVerse(surahNumber: 42, verseNumber: 4, arabicText: "هُدًى وَرَحْمَةً", translation: "Guidance and mercy", transliteration: "Hudan wa rahmah"),

        // Surah 43 – Az-Zukhruf
        QuranVerse(surahNumber: 43, verseNumber: 1, arabicText: "حم", translation: "Ha-Mim", transliteration: "Ha Mim"),
        QuranVerse(surahNumber: 43, verseNumber: 2, arabicText: "وَالْكِتَابِ الْمُبِينِ", translation: "And the clear Book", transliteration: "Wal-kitabil mubeen"),
        QuranVerse(surahNumber: 43, verseNumber: 3, arabicText: "تَنْزِيلٌ مِنَ الرَّحْمَٰنِ", translation: "Sent down from the Most Merciful", transliteration: "Tanzeelun mir-Rahman"),
        QuranVerse(surahNumber: 43, verseNumber: 4, arabicText: "حِكْمَةً وَنُورًا", translation: "With wisdom and light", transliteration: "Hikmatan wa nooran"),

        // Surah 44 – Ad-Dukhan
        QuranVerse(surahNumber: 44, verseNumber: 1, arabicText: "حم", translation: "Ha-Mim", transliteration: "Ha Mim"),
        QuranVerse(surahNumber: 44, verseNumber: 2, arabicText: "تَنزِيلٌ مِنَ الرَّحْمَٰنِ الرَّحِيمِ", translation: "A revelation from the Most Merciful, the Most Compassionate", transliteration: "Tanzeelun mir-Rahmanir-Raheem"),
        QuranVerse(surahNumber: 44, verseNumber: 3, arabicText: "كِتَابٌ مُبِينٌ", translation: "A clear Book", transliteration: "Kitabun mubeen"),
        QuranVerse(surahNumber: 44, verseNumber: 4, arabicText: "لِيَذَّكَّرَ الْمُتَّقُونَ", translation: "So that the righteous may take heed", transliteration: "Li yadhakkarul muttaqun"),

        // Surah 45 – Al-Jathiya
        QuranVerse(surahNumber: 45, verseNumber: 1, arabicText: "حم", translation: "Ha-Mim", transliteration: "Ha Mim"),
        QuranVerse(surahNumber: 45, verseNumber: 2, arabicText: "تَنزِيلٌ مِنَ الرَّحْمَٰنِ الرَّحِيمِ", translation: "A revelation from the Most Merciful, the Most Compassionate", transliteration: "Tanzeelun mir-Rahmanir-Raheem"),
        QuranVerse(surahNumber: 45, verseNumber: 3, arabicText: "كِتَابٌ مُبِينٌ", translation: "A clear Book", transliteration: "Kitabun mubeen"),
        QuranVerse(surahNumber: 45, verseNumber: 4, arabicText: "هُدًى وَرَحْمَةً لِلْمُؤْمِنِينَ", translation: "Guidance and mercy for the believers", transliteration: "Hudan wa rahmah lil-mu'mineen"),

        // Surah 46 – Al-Ahqaf
        QuranVerse(surahNumber: 46, verseNumber: 1, arabicText: "حم", translation: "Ha-Mim", transliteration: "Ha Mim"),
        QuranVerse(surahNumber: 46, verseNumber: 2, arabicText: "تَنزِيلٌ مِنَ الرَّحْمَٰنِ الرَّحِيمِ", translation: "A revelation from the Most Merciful, the Most Compassionate", transliteration: "Tanzeelun mir-Rahmanir-Raheem"),
        QuranVerse(surahNumber: 46, verseNumber: 3, arabicText: "كِتَابٌ مُبِينٌ", translation: "A clear Book", transliteration: "Kitabun mubeen"),
        QuranVerse(surahNumber: 46, verseNumber: 4, arabicText: "لِيَهْتَدُوا بِهِ", translation: "So that they may be guided by it", transliteration: "Li yahtadu bihi"),

        // Surah 47 – Muhammad
        QuranVerse(surahNumber: 47, verseNumber: 1, arabicText: "الَّذِينَ كَفَرُوا وَصَدُّوا", translation: "Those who disbelieve and hinder", transliteration: "Alladhina kafaru wa saddoo"),
        QuranVerse(surahNumber: 47, verseNumber: 2, arabicText: "عَن سَبِيلِ اللَّهِ", translation: "From the way of Allah", transliteration: "An sabeel Allah"),
        QuranVerse(surahNumber: 47, verseNumber: 3, arabicText: "فَسَيُعَذَّبُونَ", translation: "They will be punished", transliteration: "Fa sayu'adhdhaboon"),
        QuranVerse(surahNumber: 47, verseNumber: 4, arabicText: "بِشِدَّةٍ", translation: "With severity", transliteration: "Bishidda"),

        // Surah 48 – Al-Fath
        QuranVerse(surahNumber: 48, verseNumber: 1, arabicText: "إِنَّا فَتَحْنَا لَكَ فَتْحًا مُّبِينًا", translation: "Indeed We have given you a clear victory", transliteration: "Inna fatahna laka fathan mubeen"),
        QuranVerse(surahNumber: 48, verseNumber: 2, arabicText: "لِيَغْفِرَ اللَّهُ لَكَ", translation: "That Allah may forgive you", transliteration: "Li yaghfir Allahu laka"),
        QuranVerse(surahNumber: 48, verseNumber: 3, arabicText: "مَا تَقَدَّمَ مِن ذَنْبِكَ", translation: "Of your past sins", transliteration: "Ma taqaddama min dhanbik"),
        QuranVerse(surahNumber: 48, verseNumber: 4, arabicText: "وَمَا تَأَخَّرَ", translation: "And your future", transliteration: "Wa ma ta'akhkhar"),

        // Surah 49 – Al-Hujurat
        QuranVerse(surahNumber: 49, verseNumber: 1, arabicText: "يَا أَيُّهَا الَّذِينَ آمَنُوا", translation: "O you who believe", transliteration: "Ya ayyuha alladhina amanu"),
        QuranVerse(surahNumber: 49, verseNumber: 2, arabicText: "لا تَسْخَرُوا بِبَعْضِكُمْ", translation: "Do not mock one another", transliteration: "La taskharu bi ba'dikum"),
        QuranVerse(surahNumber: 49, verseNumber: 3, arabicText: "وَلَا تَلْمِزُوا أَنفُسَكُمْ", translation: "And do not defame yourselves", transliteration: "Wa la talmizu anfusakum"),
        QuranVerse(surahNumber: 49, verseNumber: 4, arabicText: "وَلَا تَنَابَزُوا بِالْأَلْقَابِ", translation: "And do not call one another by offensive nicknames", transliteration: "Wa la tanabazu bil-alqab"),

        // Surah 50 – Qaf
        QuranVerse(surahNumber: 50, verseNumber: 1, arabicText: "ق", translation: "Qaf", transliteration: "Qaf"),
        QuranVerse(surahNumber: 50, verseNumber: 2, arabicText: "وَالْقُرْآنِ الْحَكِيمِ", translation: "By the wise Qur'an", transliteration: "Wal-Qur'ani Al-Hakeem"),
        QuranVerse(surahNumber: 50, verseNumber: 3, arabicText: "إِنَّكَ لَمِنَ الْمُرْسَلِينَ", translation: "Indeed you are among the messengers", transliteration: "Innak laminal-mursaleen"),
        QuranVerse(surahNumber: 50, verseNumber: 4, arabicText: "عَلَى صِرَاطٍ مُسْتَقِيمٍ", translation: "On a straight path", transliteration: "Ala siratin mustaqeem"),
        
        // Surah 51 – Adh-Dhariyat
        QuranVerse(surahNumber: 51, verseNumber: 1, arabicText: "وَالذَّارِيَاتِ ذَرْوًا", translation: "By those that scatter [winds] dispersing", transliteration: "Wal-dhariyati dharwa"),
        QuranVerse(surahNumber: 51, verseNumber: 2, arabicText: "فَالْمُورِيَاتِ قَدْحًا", translation: "And those that drive [clouds] gently", transliteration: "Fal-muriyati qadha"),
        QuranVerse(surahNumber: 51, verseNumber: 3, arabicText: "فَالْمُغِيثَاتِ رِزْقًا", translation: "And those that bring relief", transliteration: "Fal-mughithati rizqan"),
        QuranVerse(surahNumber: 51, verseNumber: 4, arabicText: "إِنَّمَا تُوعَدُونَ لَوَاقِعٌ", translation: "Indeed what you are promised will occur", transliteration: "Innama tu'adoona lawaqi'un"),

        // Surah 52 – At-Tur
        QuranVerse(surahNumber: 52, verseNumber: 1, arabicText: "وَالطُّورِ", translation: "By the Mount", transliteration: "Wal-tur"),
        QuranVerse(surahNumber: 52, verseNumber: 2, arabicText: "وَكِتَابٍ مَّسْطُورٍ", translation: "And a written Book", transliteration: "Wa kitabin mastoor"),
        QuranVerse(surahNumber: 52, verseNumber: 3, arabicText: "فِي رَقٍّ مَّنشُورٍ", translation: "In parchment unrolled", transliteration: "Fi raqqin manshoor"),
        QuranVerse(surahNumber: 52, verseNumber: 4, arabicText: "الَّذِينَ هُمْ فِي صَلَاتِهِمْ خَاشِعُونَ", translation: "Those who humble themselves in their prayers", transliteration: "Alladhina hum fi salatihim khashi'un"),

        // Surah 53 – An-Najm
        QuranVerse(surahNumber: 53, verseNumber: 1, arabicText: "وَالنَّجْمِ إِذَا هَوَىٰ", translation: "By the star when it descends", transliteration: "Wan-najmi iza hawa"),
        QuranVerse(surahNumber: 53, verseNumber: 2, arabicText: "مَا ضَلَّ صَاحِبُكُمْ وَمَا غَوَىٰ", translation: "Your companion has not strayed, nor has he erred", transliteration: "Ma dalla sahibukum wa ma ghawa"),
        QuranVerse(surahNumber: 53, verseNumber: 3, arabicText: "وَمَا يَنطِقُ عَنِ الْهَوَىٰ", translation: "Nor does he speak from desire", transliteration: "Wa ma yantiqu 'anil-hawa"),
        QuranVerse(surahNumber: 53, verseNumber: 4, arabicText: "إِنْ هُوَ إِلَّا وَحْيٌ يُوحَىٰ", translation: "It is nothing but a revelation revealed", transliteration: "In huwa illa wahyun yooha"),

        // Surah 54 – Al-Qamar
        QuranVerse(surahNumber: 54, verseNumber: 1, arabicText: "اقْتَرَبَتِ السَّاعَةُ وَانشَقَّ الْقَمَرُ", translation: "The Hour has come near, and the moon has split", transliteration: "Iqtarabatis-sa'atu wa inshaqal-qamar"),
        QuranVerse(surahNumber: 54, verseNumber: 2, arabicText: "وَإِن يَرَوْا آيَةً يُعْرِضُوا", translation: "And if they see a sign, they turn away", transliteration: "Wa in yaraw ayatan yu'ridhu"),
        QuranVerse(surahNumber: 54, verseNumber: 3, arabicText: "وَكَذَّبُوا وَاتَّبَعُوا أَهْوَاءَهُمْ", translation: "And deny it and follow their desires", transliteration: "Wa kazzaboo wa ittaba'u ahwa'ahum"),
        QuranVerse(surahNumber: 54, verseNumber: 4, arabicText: "فَسَوْفَ يَعْلَمُونَ", translation: "Soon they will know", transliteration: "Fasawfa ya'lamoon"),

        // Surah 55 – Ar-Rahman
        QuranVerse(surahNumber: 55, verseNumber: 1, arabicText: "الرَّحْمَٰنُ", translation: "The Most Merciful", transliteration: "Ar-Rahman"),
        QuranVerse(surahNumber: 55, verseNumber: 2, arabicText: "عَلَّمَ الْقُرْآنَ", translation: "Taught the Qur'an", transliteration: "Allamal-Qur'an"),
        QuranVerse(surahNumber: 55, verseNumber: 3, arabicText: "خَلَقَ الْإِنسَانَ", translation: "Created man", transliteration: "Khalaqal-insan"),
        QuranVerse(surahNumber: 55, verseNumber: 4, arabicText: "عَلَّمَهُ الْبَيَانَ", translation: "Taught him eloquence", transliteration: "Allamahu al-bayan"),

        // Surah 56 – Al-Waqia
        QuranVerse(surahNumber: 56, verseNumber: 1, arabicText: "إِذَا وَقَعَتِ الْوَاقِعَةُ", translation: "When the Occurrence occurs", transliteration: "Iza waqatil-waqi'a"),
        QuranVerse(surahNumber: 56, verseNumber: 2, arabicText: "لَيْسَ لِوَقْعَتِهَا كَاذِبَةٌ", translation: "There is no denying its occurrence", transliteration: "Laysa li waq'atiha kazibah"),
        QuranVerse(surahNumber: 56, verseNumber: 3, arabicText: "خَافِضَةٌ رَّافِعَةٌ", translation: "Bringing low and raising high", transliteration: "Khafidatun rafi'ah"),
        QuranVerse(surahNumber: 56, verseNumber: 4, arabicText: "إِذَا رُجَّتِ الْأَرْضُ رَجًّا", translation: "When the earth is shaken violently", transliteration: "Iza rujjatil-ardu rajjan"),

        // Surah 57 – Al-Hadid
        QuranVerse(surahNumber: 57, verseNumber: 1, arabicText: "سَبَّحَ لِلَّهِ مَا فِي السَّمَاوَاتِ وَالْأَرْضِ", translation: "Whatever is in the heavens and the earth glorifies Allah", transliteration: "Subbaha lillahi ma fis-samawati wal-ard"),
        QuranVerse(surahNumber: 57, verseNumber: 2, arabicText: "هُوَ الْقَوِيُّ الْعَزِيزُ", translation: "He is the Mighty, the Wise", transliteration: "Huwa al-qawiyyu al-'azeez"),
        QuranVerse(surahNumber: 57, verseNumber: 3, arabicText: "لَهُ مُلْكُ السَّمَاوَاتِ وَالْأَرْضِ", translation: "His is the dominion of the heavens and the earth", transliteration: "Lahu mulkus-samawati wal-ard"),
        QuranVerse(surahNumber: 57, verseNumber: 4, arabicText: "يُحْيِي وَيُمِيتُ", translation: "He gives life and causes death", transliteration: "Yuhyi wa yumeetu"),

        // Surah 58 – Al-Mujadila
        QuranVerse(surahNumber: 58, verseNumber: 1, arabicText: "قَدْ سَمِعَ اللَّهُ قَوْلَ الَّتِي تُجَادِلُكَ فِي زَوْجِهَا", translation: "Allah has heard the statement of she who disputes with you concerning her husband", transliteration: "Qad sami'Allahu qawla allati tujadiluka fi zawjiha"),
        QuranVerse(surahNumber: 58, verseNumber: 2, arabicText: "وَيَحْتَسِبُونَ اللَّهَ رَبًّا", translation: "And they take Allah as Lord", transliteration: "Wa yahtasiboon Allah Rabb"),
        QuranVerse(surahNumber: 58, verseNumber: 3, arabicText: "فَاصْبِرُوا عَلَى مَا يُقَالُ", translation: "So be patient over what is said", transliteration: "Fasbiru 'ala ma yuqalu"),
        QuranVerse(surahNumber: 58, verseNumber: 4, arabicText: "وَاعْمَلُوا صَالِحًا", translation: "And do righteous deeds", transliteration: "Wa a'malu salihan"),

        // Surah 59 – Al-Hashr
        QuranVerse(surahNumber: 59, verseNumber: 1, arabicText: "سَبَّحَ لِلَّهِ مَا فِي السَّمَاوَاتِ وَالْأَرْضِ", translation: "Whatever is in the heavens and the earth glorifies Allah", transliteration: "Subbaha lillahi ma fis-samawati wal-ard"),
        QuranVerse(surahNumber: 59, verseNumber: 2, arabicText: "وَهُوَ الْعَزِيزُ الْحَكِيمُ", translation: "And He is the Mighty, the Wise", transliteration: "Wahuwa al-'azeezu al-hakeem"),
        QuranVerse(surahNumber: 59, verseNumber: 3, arabicText: "لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ", translation: "His is whatever is in the heavens and the earth", transliteration: "Lahu ma fis-samawati wa ma fil-ard"),
        QuranVerse(surahNumber: 59, verseNumber: 4, arabicText: "يُخْرِجُ الْحَيَّ مِنَ الْمَيِّتِ", translation: "He brings forth the living from the dead", transliteration: "Yukhrijul-hayya minal-mayyit"),

        // Surah 60 – Al-Mumtahina
        QuranVerse(surahNumber: 60, verseNumber: 1, arabicText: "يَا أَيُّهَا الَّذِينَ آمَنُوا", translation: "O you who believe", transliteration: "Ya ayyuha alladhina amanu"),
        QuranVerse(surahNumber: 60, verseNumber: 2, arabicText: "لَا تَتَّخِذُوا عَدُوِّي وَعَدُوَّكُمْ أَوْلِيَاءَ", translation: "Do not take My enemies and your enemies as allies", transliteration: "La tattakhithu 'aduwwi wa 'aduwwakum awliyaa"),
        QuranVerse(surahNumber: 60, verseNumber: 3, arabicText: "وَاتَّقُوا اللَّهَ", translation: "And fear Allah", transliteration: "Wa ittaqu Allah"),
        QuranVerse(surahNumber: 60, verseNumber: 4, arabicText: "لَعَلَّكُمْ تُفْلِحُونَ", translation: "So that you may succeed", transliteration: "La'allakum tuflihoon"),
        
        // Surah 61 – As-Saff
        QuranVerse(surahNumber: 61, verseNumber: 1, arabicText: "سَبَّحَ لِلَّهِ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ", translation: "Whatever is in the heavens and the earth glorifies Allah", transliteration: "Subbaha lillahi ma fis-samawati wa ma fil-ard"),
        QuranVerse(surahNumber: 61, verseNumber: 2, arabicText: "لَهُ الْمُلْكُ وَالْحَمْدُ", translation: "His is the dominion and the praise", transliteration: "Lahu al-mulku wal-hamd"),
        QuranVerse(surahNumber: 61, verseNumber: 3, arabicText: "وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ", translation: "And He is over all things competent", transliteration: "Wahuwa 'ala kulli shay'in qadeer"),
        QuranVerse(surahNumber: 61, verseNumber: 4, arabicText: "وَأَعِدُّوا لَهُم مَّا اسْتَطَعْتُم مِّن قُوَّةٍ", translation: "And prepare against them whatever you are able of power", transliteration: "Wa a'iddu lahum ma istata'tum min quwwah"),

        // Surah 62 – Al-Jumu'a
        QuranVerse(surahNumber: 62, verseNumber: 1, arabicText: "يُسَبِّحُ لِلَّهِ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ", translation: "Whatever is in the heavens and the earth glorifies Allah", transliteration: "Yusabbihu lillahi ma fis-samawati wa ma fil-ard"),
        QuranVerse(surahNumber: 62, verseNumber: 2, arabicText: "هُوَ الْقَوِيُّ الْحَكِيمُ", translation: "He is the Mighty, the Wise", transliteration: "Huwa al-qawiyyu al-hakeem"),
        QuranVerse(surahNumber: 62, verseNumber: 3, arabicText: "وَهُوَ الَّذِي أَرْسَلَ رَسُولَهُ", translation: "And He it is Who sent His Messenger", transliteration: "Wahuwa alladhi arsala rasoolahu"),
        QuranVerse(surahNumber: 62, verseNumber: 4, arabicText: "لِيَهْدِي النَّاسَ بِإِذْنِهِ", translation: "To guide the people by His permission", transliteration: "Liyahdi an-nasa bi idhnihi"),

        // Surah 63 – Al-Munafiqun
        QuranVerse(surahNumber: 63, verseNumber: 1, arabicText: "إِذَا جَاءَكَ الْمُنَافِقُونَ", translation: "When the hypocrites come to you", transliteration: "Iza ja'aka al-munafiqoon"),
        QuranVerse(surahNumber: 63, verseNumber: 2, arabicText: "يَقُولُونَ نَشْهَدُ", translation: "They say, 'We testify'", transliteration: "Yaquloon nashhadu"),
        QuranVerse(surahNumber: 63, verseNumber: 3, arabicText: "وَاللَّهُ يَعْلَمُ أَنَّهُمْ كَاذِبُونَ", translation: "But Allah knows that they are liars", transliteration: "Wallahu ya'lamu annahum kaziboon"),
        QuranVerse(surahNumber: 63, verseNumber: 4, arabicText: "وَإِذَا رَأَيْتَهُمْ يُعْجِبُكَ أَجْسَامُهُمْ", translation: "And when you see them, their forms please you", transliteration: "Wa iza ra'aytahum yu'jibuka ajsamuhum"),

        // Surah 64 – At-Taghabun
        QuranVerse(surahNumber: 64, verseNumber: 1, arabicText: "سَبَّحَ لِلَّهِ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ", translation: "Whatever is in the heavens and the earth glorifies Allah", transliteration: "Subbaha lillahi ma fis-samawati wa ma fil-ard"),
        QuranVerse(surahNumber: 64, verseNumber: 2, arabicText: "لَهُ الْمُلْكُ وَالْحَمْدُ", translation: "His is the dominion and the praise", transliteration: "Lahu al-mulku wal-hamd"),
        QuranVerse(surahNumber: 64, verseNumber: 3, arabicText: "يُحْيِي وَيُمِيتُ", translation: "He gives life and causes death", transliteration: "Yuhyi wa yumeetu"),
        QuranVerse(surahNumber: 64, verseNumber: 4, arabicText: "وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ", translation: "And He is over all things competent", transliteration: "Wahuwa 'ala kulli shay'in qadeer"),

        // Surah 65 – At-Talaq
        QuranVerse(surahNumber: 65, verseNumber: 1, arabicText: "يَا أَيُّهَا النَّبِيُّ إِذَا طَلَّقْتُمُ النِّسَاءَ", translation: "O Prophet, when you divorce women", transliteration: "Ya ayyuha an-nabiyyu iza tallaqtumu an-nisa"),
        QuranVerse(surahNumber: 65, verseNumber: 2, arabicText: "فَطَلِّقُوهُنَّ لِمَوْدَّتِهِنَّ", translation: "Divorce them for their waiting period", transliteration: "Fatalliquhunna limawaddatihinna"),
        QuranVerse(surahNumber: 65, verseNumber: 3, arabicText: "وَاحْصُوا الْعِدَّةَ", translation: "And count the waiting period", transliteration: "Wa ahsul-‘idda"),
        QuranVerse(surahNumber: 65, verseNumber: 4, arabicText: "وَاتَّقُوا اللَّهَ رَبَّكُمْ", translation: "And fear Allah your Lord", transliteration: "Wa ittaqu Allah Rabbakum"),

        // Surah 66 – At-Tahrim
        QuranVerse(surahNumber: 66, verseNumber: 1, arabicText: "يَا أَيُّهَا النَّبِيُّ لِمَ تُحَرِّمُ مَا أَحَلَّ اللَّهُ لَكَ", translation: "O Prophet, why do you prohibit what Allah has made lawful for you?", transliteration: "Ya ayyuha an-nabiyyu lima tuharrimu ma ahalla Allahu laka"),
        QuranVerse(surahNumber: 66, verseNumber: 2, arabicText: "وَاللَّهُ غَفُورٌ رَحِيمٌ", translation: "And Allah is Forgiving and Merciful", transliteration: "Wallahu ghafurun raheem"),
        QuranVerse(surahNumber: 66, verseNumber: 3, arabicText: "فَتُوبُوا إِلَى اللَّهِ", translation: "So repent to Allah", transliteration: "Fatubu ila Allah"),
        QuranVerse(surahNumber: 66, verseNumber: 4, arabicText: "وَأَصْلِحُوا أَمْرَكُمْ", translation: "And correct your affairs", transliteration: "Wa aslihu amrakum"),

        // Surah 67 – Al-Mulk
        QuranVerse(surahNumber: 67, verseNumber: 1, arabicText: "تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ", translation: "Blessed is He in whose hand is dominion", transliteration: "Tabarakalladhi biyadihi al-mulk"),
        QuranVerse(surahNumber: 67, verseNumber: 2, arabicText: "وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ", translation: "And He is over all things competent", transliteration: "Wahuwa 'ala kulli shay'in qadeer"),
        QuranVerse(surahNumber: 67, verseNumber: 3, arabicText: "الَّذِي خَلَقَ الْمَوْتَ وَالْحَيَاةَ", translation: "He who created death and life", transliteration: "Alladhi khalaqal-mawta wal-hayah"),
        QuranVerse(surahNumber: 67, verseNumber: 4, arabicText: "لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا", translation: "To test you who is best in deeds", transliteration: "Li yabluwakum ayyukum ahsanu 'amala"),

        // Surah 68 – Al-Qalam
        QuranVerse(surahNumber: 68, verseNumber: 1, arabicText: "ن وَالْقَلَمِ وَمَا يَسْطُرُونَ", translation: "Nun. By the pen and what they write", transliteration: "Nun wal-qalami wa ma yasturoon"),
        QuranVerse(surahNumber: 68, verseNumber: 2, arabicText: "مَا أَنْتَ بِنِعْمَةِ رَبِّكَ بِمَجْنُونٍ", translation: "You are not, by the favor of your Lord, insane", transliteration: "Ma anta bini'mati rabbika bimajnoon"),
        QuranVerse(surahNumber: 68, verseNumber: 3, arabicText: "لِتُنذِرَ قَوْمًا مَّا أُنذِرَ آبَاؤُهُمْ", translation: "To warn a people whose forefathers were not warned", transliteration: "Litunzira qawman ma unzira abawuhum"),
        QuranVerse(surahNumber: 68, verseNumber: 4, arabicText: "لَقَدْ حَقَّ الْقَوْلُ عَلَى أَكْثَرِهِمْ", translation: "Certainly has the word proved true against most of them", transliteration: "Laqad haqqal-qawlu 'ala aktharihim"),

        // Surah 69 – Al-Haaqqa
        QuranVerse(surahNumber: 69, verseNumber: 1, arabicText: "الْحَاقَّةُ", translation: "The Inevitable", transliteration: "Al-Haaqqa"),
        QuranVerse(surahNumber: 69, verseNumber: 2, arabicText: "مَا الْحَاقَّةُ", translation: "What is the Inevitable?", transliteration: "Ma al-Haaqqa"),
        QuranVerse(surahNumber: 69, verseNumber: 3, arabicText: "وَمَا أَدْرَاكَ مَا الْحَاقَّةُ", translation: "And what will make you know what the Inevitable is?", transliteration: "Wa ma adraka ma al-Haaqqa"),
        QuranVerse(surahNumber: 69, verseNumber: 4, arabicText: "كَرَّتِ الْفُلْكُ", translation: "Thundering is the occurrence", transliteration: "Karratil-fulk"),

        // Surah 70 – Al-Ma'arij
        QuranVerse(surahNumber: 70, verseNumber: 1, arabicText: "سَأَلَ سَائِلٌ بِعَذَابٍ وَاقِعٍ", translation: "A questioner asked about a punishment bound to happen", transliteration: "Sa'ala sa'ilun bi 'adhabin waqi"),
        QuranVerse(surahNumber: 70, verseNumber: 2, arabicText: "لِلْمُكَذِّبِينَ ضِيقٌ", translation: "For the deniers, there is a narrowness", transliteration: "Lil-mukaththibina deeq"),
        QuranVerse(surahNumber: 70, verseNumber: 3, arabicText: "وَهُوَ إِلَى اللَّهِ يُرْجَعُ", translation: "And it is to Allah that they will return", transliteration: "Wa huwa ila Allahi yurja"),
        QuranVerse(surahNumber: 70, verseNumber: 4, arabicText: "فَصْبِرْ صَبْرًا جَمِيلًا", translation: "So be patient with a beautiful patience", transliteration: "Fasbir sabran jameel"),

        // Surah 71 – Nuh
        QuranVerse(surahNumber: 71, verseNumber: 1, arabicText: "إِنَّا أَرْسَلْنَا نُوحًا إِلَىٰ قَوْمِهِ", translation: "Indeed We sent Noah to his people", transliteration: "Inna arsalna Nuhan ila qawmihi"),
        QuranVerse(surahNumber: 71, verseNumber: 2, arabicText: "أَنْ أَنْذِرْ قَوْمَكَ", translation: "To warn your people", transliteration: "An undhir qawmaka"),
        QuranVerse(surahNumber: 71, verseNumber: 3, arabicText: "فَكَذَّبُوهُ", translation: "But they denied him", transliteration: "Fa kazzaboohu"),
        QuranVerse(surahNumber: 71, verseNumber: 4, arabicText: "فَأَنْجَيْنَاهُ وَمَنْ مَعَهُ فِي الْفُلْكِ", translation: "So We saved him and those with him in the ark", transliteration: "Fa anjaynahu wa man ma'ahu fil-fulk"),
        
        // Surah 72 – Al-Jinn
        QuranVerse(surahNumber: 72, verseNumber: 1, arabicText: "قُلْ أُوحِيَ إِلَيَّ أَنَّهُ اسْتَمَعَ نَفَرٌ مِّنَ الْجِنِّ", translation: "Say: It has been revealed to me that a group of jinn listened", transliteration: "Qul uwhiya ilayya annahu istama'a nafarun minal-jinn"),
        QuranVerse(surahNumber: 72, verseNumber: 2, arabicText: "فَقَالُوا إِنَّا سَمِعْنَا قُرْآنًا عَجَبًا", translation: "They said, 'Indeed we have heard a marvelous Qur'an'", transliteration: "Faqaloo inna sami'na qur'anun 'ajaban"),
        QuranVerse(surahNumber: 72, verseNumber: 3, arabicText: "يَهْدِي إِلَى الرُّشْدِ", translation: "It guides to the right path", transliteration: "Yahdi ila ar-rushd"),
        QuranVerse(surahNumber: 72, verseNumber: 4, arabicText: "فَآمَنَّا بِهِ", translation: "So we believed in it", transliteration: "Fa amanna bihi"),

        // Surah 73 – Al-Muzzammil
        QuranVerse(surahNumber: 73, verseNumber: 1, arabicText: "يَا أَيُّهَا الْمُزَّمِّلُ", translation: "O you who wraps himself [in clothing]", transliteration: "Ya ayyuha al-muzzammil"),
        QuranVerse(surahNumber: 73, verseNumber: 2, arabicText: "قُمِ اللَّيْلَ إِلَّا قَلِيلًا", translation: "Stand [in prayer] all night except a little", transliteration: "Qumil-layla illa qalilan"),
        QuranVerse(surahNumber: 73, verseNumber: 3, arabicText: "نِصْفَهُ أَوِ انقُصْ مِنْهُ قَلِيلًا", translation: "Half of it or subtract a little from it", transliteration: "Nisfahu awinqus minhu qalilan"),
        QuranVerse(surahNumber: 73, verseNumber: 4, arabicText: "أَوْ زِدْ عَلَيْهِ وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا", translation: "Or add to it, and recite the Qur'an with measured recitation", transliteration: "Aw zid 'alayhi wa rattilil-Qur'an tartila"),

        // Surah 74 – Al-Muddathir
        QuranVerse(surahNumber: 74, verseNumber: 1, arabicText: "يَا أَيُّهَا الْمُدَّثِّرُ", translation: "O you who covers himself [with a garment]", transliteration: "Ya ayyuha al-muddathir"),
        QuranVerse(surahNumber: 74, verseNumber: 2, arabicText: "قُمْ فَأَنذِرْ", translation: "Arise and warn", transliteration: "Qum fa andhir"),
        QuranVerse(surahNumber: 74, verseNumber: 3, arabicText: "وَرَبَّكَ فَكَبِّرْ", translation: "And magnify your Lord", transliteration: "Wa rabbaka fakabbir"),
        QuranVerse(surahNumber: 74, verseNumber: 4, arabicText: "وَثِيَابَكَ فَطَهِّرْ", translation: "And purify your garments", transliteration: "Wa thiyabaka fathahir"),

        // Surah 75 – Al-Qiyamah
        QuranVerse(surahNumber: 75, verseNumber: 1, arabicText: "لَا أُقْسِمُ بِيَوْمِ الْقِيَامَةِ", translation: "I swear by the Day of Resurrection", transliteration: "La uqsimu biyawmi al-qiyamah"),
        QuranVerse(surahNumber: 75, verseNumber: 2, arabicText: "وَلَا أُقْسِمُ بِالنَّفْسِ اللَّوَّامَةِ", translation: "And I swear by the self-reproaching soul", transliteration: "Wa la uqsimu bin-nafsi al-lawwamah"),
        QuranVerse(surahNumber: 75, verseNumber: 3, arabicText: "أَيَحْسَبُ الْإِنسَانُ أَلَّن نَّجْمَعَ عِظَامَهُ", translation: "Does man think that We will not assemble his bones?", transliteration: "Ayahsabu al-insanu allan najma'a 'izamahu"),
        QuranVerse(surahNumber: 75, verseNumber: 4, arabicText: "بَلَى قَادِرِينَ عَلَى أَن نُّسَوِّيَ بَنَانَهُ", translation: "Yes, We are able to proportion his fingertips", transliteration: "Bala qadireena 'ala an nusawwiya bananahu"),

        // Surah 76 – Al-Insan
        QuranVerse(surahNumber: 76, verseNumber: 1, arabicText: "هَلْ أَتَىٰ عَلَى الْإِنسَانِ حِينٌ مِّنَ الدَّهْرِ", translation: "Has there come upon man a period of time", transliteration: "Hal ata 'ala al-insani hinun minal-dahr"),
        QuranVerse(surahNumber: 76, verseNumber: 2, arabicText: "إِذْ كَانَ لَا شَيْءَ مَذْكُورًا", translation: "When he was not a thing mentioned?", transliteration: "Idh kana la shay'a madhkuran"),
        QuranVerse(surahNumber: 76, verseNumber: 3, arabicText: "إِنَّا خَلَقْنَا الْإِنسَانَ مِن نُّطْفَةٍ أَمْشَاجٍ", translation: "Indeed We created man from a sperm-drop mixture", transliteration: "Inna khalaqnal-insana min nutfatin amshaj"),
        QuranVerse(surahNumber: 76, verseNumber: 4, arabicText: "لِنَبْلُوَهُ فَنَجْعَلَهُ سَمِيعًا بَصِيرًا", translation: "To test him; and We made him hearing and seeing", transliteration: "Linabluwahu naj'alahu sami'an basiran"),

        // Surah 77 – Al-Mursalat
        QuranVerse(surahNumber: 77, verseNumber: 1, arabicText: "وَالْمُرْسَلَاتِ عُرْفًا", translation: "By those [winds] sent forth one after another", transliteration: "Wal-mursalat 'urfa"),
        QuranVerse(surahNumber: 77, verseNumber: 2, arabicText: "فَالْعَاصِفَاتِ عَاصِفًا", translation: "And the stormy winds", transliteration: "Fal-'asifati 'asifa"),
        QuranVerse(surahNumber: 77, verseNumber: 3, arabicText: "فَالنَّاشِرَاتِ نَشْرًا", translation: "And those that spread [something] far and wide", transliteration: "Fannashirati nashra"),
        QuranVerse(surahNumber: 77, verseNumber: 4, arabicText: "فَالْمُكَذِّبَاتِ ضِدًّا", translation: "And those who deny, opposing", transliteration: "Falmukaththibati diddan"),

        // Surah 78 – An-Naba
        QuranVerse(surahNumber: 78, verseNumber: 1, arabicText: "عَمَّ يَتَسَاءَلُونَ", translation: "About what are they asking one another?", transliteration: "'Amma yatasa'aloon"),
        QuranVerse(surahNumber: 78, verseNumber: 2, arabicText: "عَنِ النَّبَإِ الْعَظِيمِ", translation: "About the Great News", transliteration: "Anin-naba'il-azim"),
        QuranVerse(surahNumber: 78, verseNumber: 3, arabicText: "الَّذِي هُمْ فِيهِ مُخْتَلِفُونَ", translation: "Over which they are in disagreement", transliteration: "Alladhi hum fihi mukhtalifoon"),
        QuranVerse(surahNumber: 78, verseNumber: 4, arabicText: "كَلَّا سَيَعْلَمُونَ", translation: "No! They will come to know", transliteration: "Kalla saya'lamoon"),

        // Surah 79 – An-Nazi'at
        QuranVerse(surahNumber: 79, verseNumber: 1, arabicText: "وَالنَّازِعَاتِ غَرْقًا", translation: "By those who extract with violence", transliteration: "Wan-nazi'ati gharqa"),
        QuranVerse(surahNumber: 79, verseNumber: 2, arabicText: "وَالنَّاشِطَاتِ نَشْطًا", translation: "And those who gently draw out", transliteration: "Wan-nashitati nashta"),
        QuranVerse(surahNumber: 79, verseNumber: 3, arabicText: "وَالسَّابِحَاتِ سَبْحًا", translation: "And those who glide along", transliteration: "Was-sabihat sabha"),
        QuranVerse(surahNumber: 79, verseNumber: 4, arabicText: "فَالسَّابِقَاتِ سَبْقًا", translation: "And those who race each other in speed", transliteration: "Fas-sabiqun sabqa"),

        // Surah 80 – Abasa
        QuranVerse(surahNumber: 80, verseNumber: 1, arabicText: "عَبَسَ وَتَوَلَّىٰ", translation: "He frowned and turned away", transliteration: "Abasa wa tawalla"),
        QuranVerse(surahNumber: 80, verseNumber: 2, arabicText: "أَنْ جَاءَهُ الْأَعْمَىٰ", translation: "Because there came to him the blind man", transliteration: "An ja'ahu al-a'ma"),
        QuranVerse(surahNumber: 80, verseNumber: 3, arabicText: "وَمَا يُدْرِيكَ لَعَلَّهُ يَزْكِي", translation: "And what could tell you? Perhaps he might grow in purity", transliteration: "Wa ma yudrika la'allahu yazki"),
        QuranVerse(surahNumber: 80, verseNumber: 4, arabicText: "أَوْ يَذَّكَّرُ فَتَنفَعَهُ الذِّكْرَىٰ", translation: "Or receive admonition so the reminder benefits him", transliteration: "Aw yadhakkaru fatanfa'ahu adh-dhikra"),

        // Surah 81 – At-Takwir
        QuranVerse(surahNumber: 81, verseNumber: 1, arabicText: "إِذَا الشَّمْسُ كُوِّرَتْ", translation: "When the sun is wrapped up [in darkness]", transliteration: "Iza ash-shamsu kuwwirat"),
        QuranVerse(surahNumber: 81, verseNumber: 2, arabicText: "وَإِذَا الْكَوَاكِبُ انْتَثَرَتْ", translation: "And when the stars fall, dispersing", transliteration: "Wa iza al-kawakibu intatharat"),
        QuranVerse(surahNumber: 81, verseNumber: 3, arabicText: "وَإِذَا الْجِبَالُ نُسِفَتْ", translation: "And when the mountains are removed", transliteration: "Wa iza al-jibalu nusifat"),
        QuranVerse(surahNumber: 81, verseNumber: 4, arabicText: "وَإِذَا الرُّسُلُ أُقِّتَتْ", translation: "And when the messengers are appointed", transliteration: "Wa iza ar-rusulu uqqitat"),

        // Surah 82 – Al-Infitar
        QuranVerse(surahNumber: 82, verseNumber: 1, arabicText: "إِذَا السَّمَاءُ انفَطَرَتْ", translation: "When the sky breaks apart", transliteration: "Iza as-sama' infatarat"),
        QuranVerse(surahNumber: 82, verseNumber: 2, arabicText: "وَإِذَا الْكَوَاكِبُ انتَثَرَتْ", translation: "And when the stars are scattered", transliteration: "Wa iza al-kawakibu intatharat"),
        QuranVerse(surahNumber: 82, verseNumber: 3, arabicText: "وَإِذَا الْبِحَارُ فُجِّرَتْ", translation: "And when the seas are burst forth", transliteration: "Wa iza al-biharu fujirat"),
        QuranVerse(surahNumber: 82, verseNumber: 4, arabicText: "وَإِذَا الْقُبُورُ بُعْثِرَتْ", translation: "And when the graves are overturned", transliteration: "Wa iza al-qubooru bu'thirat"),

        // Surah 83 – Al-Mutaffifin
        QuranVerse(surahNumber: 83, verseNumber: 1, arabicText: "وَيْلٌ لِلْمُطَفِّفِينَ", translation: "Woe to those who give less [than due]", transliteration: "Waylun lil-mutaffifin"),
        QuranVerse(surahNumber: 83, verseNumber: 2, arabicText: "الَّذِينَ إِذَا اكْتَالُوا عَلَى النَّاسِ يَسْتَوْفُونَ", translation: "Who, when they take a measure from people, take in full", transliteration: "Alladhina idha iktalu 'ala an-nasi yastawfun"),
        QuranVerse(surahNumber: 83, verseNumber: 3, arabicText: "وَإِذَا كَالُوهُمْ أَوْ وَزَنُوهُمْ يُخْسِرُونَ", translation: "But when they measure or weigh for others, they give less", transliteration: "Wa idha kaluhum aw wazanuhum yukhsirun"),
        QuranVerse(surahNumber: 83, verseNumber: 4, arabicText: "أَلَا يَظُنُّ أُوْلَئِكَ أَنَّهُم مَّبْعُوثُونَ", translation: "Do they not think that they will be resurrected?", transliteration: "Ala yazunnu ulai'ka annahum mab'uthun"),

        // Surah 84 – Al-Inshiqaq
        QuranVerse(surahNumber: 84, verseNumber: 1, arabicText: "إِذَا السَّمَاءُ انشَقَّتْ", translation: "When the sky is split open", transliteration: "Iza as-sama' inshaqat"),
        QuranVerse(surahNumber: 84, verseNumber: 2, arabicText: "وَأَذِنَتِ الْمَلاَئِكَةُ", translation: "And the angels obeyed", transliteration: "Wa adh-dhinatil-mala'ikah"),
        QuranVerse(surahNumber: 84, verseNumber: 3, arabicText: "وَأُمِرَتِ الْأَرْضُ", translation: "And the earth was commanded", transliteration: "Wa umiratil-ard"),
        QuranVerse(surahNumber: 84, verseNumber: 4, arabicText: "وَأَخْرَجَتْ مَا فِيهَا", translation: "And it brought forth what was in it", transliteration: "Wa akhrajat ma fiha"),

        // Surah 85 – Al-Buruj
        QuranVerse(surahNumber: 85, verseNumber: 1, arabicText: "وَالسَّمَاءِ ذَاتِ الْبُرُوجِ", translation: "By the sky containing constellations", transliteration: "Was-sama' dhatil-buruj"),
        QuranVerse(surahNumber: 85, verseNumber: 2, arabicText: "وَالْيَوْمِ الْمَوْعُودِ", translation: "And the promised day", transliteration: "Wal-yawmil-ma'ud"),
        QuranVerse(surahNumber: 85, verseNumber: 3, arabicText: "وَشَاهِدٍ وَمَشْهُودٍ", translation: "And the witness and the witnessed", transliteration: "Wa shahidin wa mashhood"),
        QuranVerse(surahNumber: 85, verseNumber: 4, arabicText: "قُتِلَ أَصْحَابُ الْأُخْدُودِ", translation: "Cursed were the owners of the trench", transliteration: "Qutila ash-habu al-ukhdoood"),
        
        // Surah 86 – At-Tariq
        QuranVerse(surahNumber: 86, verseNumber: 1, arabicText: "وَالسَّمَاءِ وَالطَّارِقِ", translation: "By the sky and the morning star", transliteration: "Was-sama' wat-tariq"),
        QuranVerse(surahNumber: 86, verseNumber: 2, arabicText: "وَمَا أَدْرَاكَ مَا الطَّارِقُ", translation: "And what will make you know what the morning star is?", transliteration: "Wa ma adraka ma at-tariq"),
        QuranVerse(surahNumber: 86, verseNumber: 3, arabicText: "النَّجْمُ الثَّاقِبُ", translation: "The piercing star", transliteration: "An-najmu ath-thaqib"),
        QuranVerse(surahNumber: 86, verseNumber: 4, arabicText: "إِن كُلُّ نَفْسٍ لَمَّا عَلَيْهَا حَافِظٌ", translation: "Indeed, every soul has a guardian over it", transliteration: "Inna kullu nafsin lamma 'alayha hafiz"),

        // Surah 87 – Al-Ala
        QuranVerse(surahNumber: 87, verseNumber: 1, arabicText: "سَبِّحِ اسْمَ رَبِّكَ الْأَعْلَى", translation: "Exalt the name of your Lord, the Most High", transliteration: "Sabbih isma rabbikal a'la"),
        QuranVerse(surahNumber: 87, verseNumber: 2, arabicText: "الَّذِي خَلَقَ فَسَوَّىٰ", translation: "Who created and proportioned", transliteration: "Alladhi khalaqa fasawwa"),
        QuranVerse(surahNumber: 87, verseNumber: 3, arabicText: "وَالَّذِي قَدَّرَ فَهَدَىٰ", translation: "And Who determined and guided", transliteration: "Walladhi qaddara fahada"),
        QuranVerse(surahNumber: 87, verseNumber: 4, arabicText: "وَالَّذِي أَخْرَجَ الْمَرْعَىٰ", translation: "And Who brings out the pasture", transliteration: "Walladhi akhrajal mar'aa"),

        // Surah 88 – Al-Ghashiyah
        QuranVerse(surahNumber: 88, verseNumber: 1, arabicText: "هَلْ أَتَىٰكَ حَدِيثُ الْغَاشِيَةِ", translation: "Has there reached you the report of the Overwhelming?", transliteration: "Hal ataka hadithul ghashiyah"),
        QuranVerse(surahNumber: 88, verseNumber: 2, arabicText: "وُجُوهٌ يَوْمَئِذٍ خَاشِعَةٌ", translation: "Some faces, that Day, will be humbled", transliteration: "Wujuhun yawma'ithin khashi'ah"),
        QuranVerse(surahNumber: 88, verseNumber: 3, arabicText: "عَامِلَةٌ نَّاصِبَةٌ", translation: "Working hard and exhausted", transliteration: "Aamilatun nasibah"),
        QuranVerse(surahNumber: 88, verseNumber: 4, arabicText: "تَصْلَىٰ نَارًا حَامِيَةً", translation: "They will be exposed to a scorching fire", transliteration: "Tasla naran hamiyah"),

        // Surah 89 – Al-Fajr
        QuranVerse(surahNumber: 89, verseNumber: 1, arabicText: "وَالْفَجْرِ", translation: "By the dawn", transliteration: "Wal-fajr"),
        QuranVerse(surahNumber: 89, verseNumber: 2, arabicText: "وَلَيَالٍ عَشْرٍ", translation: "And [by] ten nights", transliteration: "Wa layalin 'ashr"),
        QuranVerse(surahNumber: 89, verseNumber: 3, arabicText: "وَالشَّفْعِ وَالْوَتْرِ", translation: "And [by] the even and the odd", transliteration: "Wash-shaf'i wal-watr"),
        QuranVerse(surahNumber: 89, verseNumber: 4, arabicText: "وَاللَّيْلِ إِذَا يَسْرِ", translation: "And [by] the night when it passes", transliteration: "Wallayli iza yasr"),

        // Surah 90 – Al-Balad
        QuranVerse(surahNumber: 90, verseNumber: 1, arabicText: "لَا أُقْسِمُ بِهَذَا الْبَلَدِ", translation: "I swear by this city [Makkah]", transliteration: "La uqsimu bihazal balad"),
        QuranVerse(surahNumber: 90, verseNumber: 2, arabicText: "وَأَنْتَ حِلٌّ بِهَذَا الْبَلَدِ", translation: "And you are a resident of this city", transliteration: "Wa anta hillun bihazal balad"),
        QuranVerse(surahNumber: 90, verseNumber: 3, arabicText: "وَوَالِدٍ وَمَا وَلَدَ", translation: "And [by] a father and what he begot", transliteration: "Wa walidin wa ma walad"),
        QuranVerse(surahNumber: 90, verseNumber: 4, arabicText: "لَقَدْ خَلَقْنَا الْإِنسَانَ فِي كَبَدٍ", translation: "Indeed, We have created man into hardship", transliteration: "Laqad khalaqal-insana fi kabad"),
        
        // Surah 90 – Al-Balad
        QuranVerse(surahNumber: 90, verseNumber: 1, arabicText: "لَا أُقْسِمُ بِهَذَا الْبَلَدِ", translation: "I swear by this city", transliteration: "La uqsimu bihadha al-balad"),
        QuranVerse(surahNumber: 90, verseNumber: 2, arabicText: "وَأَنْتَ حِلٌّ بِهَا", translation: "And you are free within it", transliteration: "Wa anta hillun biha"),
        QuranVerse(surahNumber: 90, verseNumber: 3, arabicText: "وَوَالِدٍ وَمَا وَلَدَ", translation: "And by a parent and what he has begotten", transliteration: "Wa walidin wa ma walad"),
        QuranVerse(surahNumber: 90, verseNumber: 4, arabicText: "لَقَدْ خَلَقْنَا الْإِنْسَانَ فِي كَبَدٍ", translation: "Indeed We have created man in toil", transliteration: "Laqad khalaqnal-insana fi kabad"),

        // Surah 91 – Ash-Shams
        QuranVerse(surahNumber: 91, verseNumber: 1, arabicText: "وَالشَّمْسِ وَضُحَاهَا", translation: "By the sun and its brightness", transliteration: "Wash-shamsi wa duhaha"),
        QuranVerse(surahNumber: 91, verseNumber: 2, arabicText: "وَالْقَمَرِ إِذَا تَلَاهَا", translation: "And the moon when it follows it", transliteration: "Wal-qamari iza talaha"),
        QuranVerse(surahNumber: 91, verseNumber: 3, arabicText: "وَالنَّهَارِ إِذَا جَلَّاهَا", translation: "And the day when it displays it", transliteration: "Wan-nahari iza jallaha"),
        QuranVerse(surahNumber: 91, verseNumber: 4, arabicText: "وَاللَّيْلِ إِذَا يَغْشَاهَا", translation: "And the night when it covers it", transliteration: "Wal-layli iza yaghshaha"),

        // Surah 92 – Al-Lail
        QuranVerse(surahNumber: 92, verseNumber: 1, arabicText: "وَاللَّيْلِ إِذَا يَغْشَاهَا", translation: "By the night when it covers", transliteration: "Wal-layli iza yaghshaha"),
        QuranVerse(surahNumber: 92, verseNumber: 2, arabicText: "وَالنَّهَارِ إِذَا تَبَدَّاهَا", translation: "And the day when it unveils", transliteration: "Wan-nahari iza tabaddaha"),
        QuranVerse(surahNumber: 92, verseNumber: 3, arabicText: "وَمَا خَلَقَ الذَّكَرَ وَالْأُنْثَىٰ", translation: "And He created the male and the female", transliteration: "Wa ma khalaqaz-zakara wal-untha"),
        QuranVerse(surahNumber: 92, verseNumber: 4, arabicText: "إِنَّ سَعْيَكُمْ لَشَتَّىٰ", translation: "Indeed, your efforts are diverse", transliteration: "Inna sa'yakum lashatta"),

        // Surah 93 – Ad-Duha
        QuranVerse(surahNumber: 93, verseNumber: 1, arabicText: "وَالضُّحَىٰ", translation: "By the morning brightness", transliteration: "Wad-duha"),
        QuranVerse(surahNumber: 93, verseNumber: 2, arabicText: "وَاللَّيْلِ إِذَا سَجَىٰ", translation: "And the night when it covers with darkness", transliteration: "Wallayli iza saja"),
        QuranVerse(surahNumber: 93, verseNumber: 3, arabicText: "مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ", translation: "Your Lord has neither forsaken you nor hated you", transliteration: "Ma wadd'aka rabbuka wa ma qala"),
        QuranVerse(surahNumber: 93, verseNumber: 4, arabicText: "وَلَلْآخِرَةُ خَيْرٌ لَّكَ مِنَ الْأُولَىٰ", translation: "And the Hereafter is better for you than the first [life]", transliteration: "Walil-akhiratu khayrun laka minal-oola"),

        // Surah 94 – Ash-Sharh
        QuranVerse(surahNumber: 94, verseNumber: 1, arabicText: "أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ", translation: "Did We not expand for you your chest?", transliteration: "Alam nashrah laka sadrak"),
        QuranVerse(surahNumber: 94, verseNumber: 2, arabicText: "وَوَضَعْنَا عَنكَ وِزْرَكَ", translation: "And remove from you your burden", transliteration: "Wa wada'na 'anka wizrak"),
        QuranVerse(surahNumber: 94, verseNumber: 3, arabicText: "وَرَفَعْنَا لَكَ ذِكْرَكَ", translation: "And We raised high your repute", transliteration: "Wa rafa'na laka dhikrak"),
        QuranVerse(surahNumber: 94, verseNumber: 4, arabicText: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا", translation: "For indeed, with hardship [will be] ease", transliteration: "Fa inna ma'al usri yusra"),

        // Surah 95 – At-Tin
        QuranVerse(surahNumber: 95, verseNumber: 1, arabicText: "وَالتِّينِ وَالزَّيْتُونِ", translation: "By the fig and the olive", transliteration: "Wat-tin waz-zaytun"),
        QuranVerse(surahNumber: 95, verseNumber: 2, arabicText: "وَطُورِ سِينِينَ", translation: "And Mount Sinai", transliteration: "Wa turi sinin"),
        QuranVerse(surahNumber: 95, verseNumber: 3, arabicText: "وَهَذَا الْبَلَدِ الْأَمِينِ", translation: "And this secure city [Makkah]", transliteration: "Wa hadha al-baladil-amin"),
        QuranVerse(surahNumber: 95, verseNumber: 4, arabicText: "لَقَدْ خَلَقْنَا الْإِنْسَانَ فِي أَحْسَنِ تَقْوِيمٍ", translation: "We have certainly created man in the best of stature", transliteration: "Laqad khalaqnal-insana fi ahsani taqweem"),

        // Surah 96 – Al-Alaq
        QuranVerse(surahNumber: 96, verseNumber: 1, arabicText: "اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ", translation: "Recite in the name of your Lord who created", transliteration: "Iqra' bismi rabbika alladhi khalaq"),
        QuranVerse(surahNumber: 96, verseNumber: 2, arabicText: "خَلَقَ الْإِنْسَانَ مِنْ عَلَقٍ", translation: "Created man from a clot", transliteration: "Khalaqal-insana min 'alaq"),
        QuranVerse(surahNumber: 96, verseNumber: 3, arabicText: "اقْرَأْ وَرَبُّكَ الْأَكْرَمُ", translation: "Recite, and your Lord is the Most Generous", transliteration: "Iqra' wa rabbuka al-akram"),
        QuranVerse(surahNumber: 96, verseNumber: 4, arabicText: "الَّذِي عَلَّمَ بِالْقَلَمِ", translation: "Who taught by the pen", transliteration: "Alladhi 'allama bil-qalam"),

        // Surah 97 – Al-Qadr
        QuranVerse(surahNumber: 97, verseNumber: 1, arabicText: "إِنَّا أَنزَلْنَاهُ فِي لَيْلَةِ الْقَدْرِ", translation: "Indeed, We sent it [Qur'an] down on the Night of Decree", transliteration: "Inna anzalnahu fi laylatil-qadr"),
        QuranVerse(surahNumber: 97, verseNumber: 2, arabicText: "وَمَا أَدْرَاكَ مَا لَيْلَةُ الْقَدْرِ", translation: "And what can make you know what is the Night of Decree?", transliteration: "Wa ma adraka ma laylatul-qadr"),
        QuranVerse(surahNumber: 97, verseNumber: 3, arabicText: "لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ", translation: "The Night of Decree is better than a thousand months", transliteration: "Laylatul-qadri khayrun min alfi shahr"),
        QuranVerse(surahNumber: 97, verseNumber: 4, arabicText: "تَنَزَّلُ الْمَلَائِكَةُ وَالرُّوحُ فِيهَا", translation: "The angels and the Spirit descend therein", transliteration: "Tanazzalul-mala'ikatu war-ruhu fiha"),

        // Surah 98 – Al-Bayyina
        QuranVerse(surahNumber: 98, verseNumber: 1, arabicText: "لَمْ يَكُنِ الَّذِينَ كَفَرُوا مِنْ أَهْلِ الْكِتَابِ", translation: "Those who disbelieved among the People of the Scripture", transliteration: "Lam yakunilladhina kafaru min ahli al-kitab"),
        QuranVerse(surahNumber: 98, verseNumber: 2, arabicText: "وَالْمُشْرِكُونَ مُنفَكِّينَ", translation: "And the polytheists separate until...", transliteration: "Wal-mushrikuna munfakikun"),
        QuranVerse(surahNumber: 98, verseNumber: 3, arabicText: "لَمْ يَنْزِلْ عَلَيْهِمْ بَيِّنَةٌ", translation: "There came to them clear evidence", transliteration: "Lam yanzil 'alayhim bayyina"),
        QuranVerse(surahNumber: 98, verseNumber: 4, arabicText: "رَسُولٌ مِنَ اللَّهِ", translation: "A Messenger from Allah", transliteration: "Rasoolun min Allah"),

        // Surah 99 – Az-Zalzalah
        QuranVerse(surahNumber: 99, verseNumber: 1, arabicText: "إِذَا زُلْزِلَتِ الْأَرْضُ زِلْزَالَهَا", translation: "When the earth is shaken with its [final] earthquake", transliteration: "Iza zulzilatil-ardh zilzalaha"),
        QuranVerse(surahNumber: 99, verseNumber: 2, arabicText: "وَأَخْرَجَتِ الْأَرْضُ أَثْقَالَهَا", translation: "And the earth discharges its burdens", transliteration: "Wa akhrajatil-ardh athqalaha"),
        QuranVerse(surahNumber: 99, verseNumber: 3, arabicText: "وَقَالَ الْإِنسَانُ مَا لَهَا", translation: "And man says, 'What is wrong with it?'", transliteration: "Wa qalal-insanu ma laha"),
        QuranVerse(surahNumber: 99, verseNumber: 4, arabicText: "يَوْمَئِذٍ تُحَدِّثُ أَخْبَارَهَا", translation: "That Day it will declare its information", transliteration: "Yawma-idh tuhaddithu akhbaraha"),

        // Surah 100 – Al-Adiyat
        QuranVerse(surahNumber: 100, verseNumber: 1, arabicText: "وَالْعَادِيَاتِ ضَبْحًا", translation: "By the chargers, panting", transliteration: "Wal-adiyati dabhan"),
        QuranVerse(surahNumber: 100, verseNumber: 2, arabicText: "فَالْمُورِيَاتِ قَدْحًا", translation: "And the raiders at dawn", transliteration: "Fal-muriyati qadhan"),
        QuranVerse(surahNumber: 100, verseNumber: 3, arabicText: "فَالْمُغِيرَاتِ صُبْحًا", translation: "And the attackers at morning", transliteration: "Fal-mughirati subhan"),
        QuranVerse(surahNumber: 100, verseNumber: 4, arabicText: "فَأَثَرْنَ بِهِ نَقْعًا", translation: "Striking with it sparks of fire", transliteration: "Fa atharna bihi naqa"),

        // Surah 101 – Al-Qari'a
        QuranVerse(surahNumber: 101, verseNumber: 1, arabicText: "الْقَارِعَةُ", translation: "The Striking Calamity", transliteration: "Al-Qari'a"),
        QuranVerse(surahNumber: 101, verseNumber: 2, arabicText: "مَا الْقَارِعَةُ", translation: "What is the Striking Calamity?", transliteration: "Ma al-Qari'a"),
        QuranVerse(surahNumber: 101, verseNumber: 3, arabicText: "وَمَا أَدْرَاكَ مَا الْقَارِعَةُ", translation: "And what can make you know what is the Striking Calamity?", transliteration: "Wa ma adraka ma al-Qari'a"),
        QuranVerse(surahNumber: 101, verseNumber: 4, arabicText: "يَوْمَ يَكُونُ النَّاسُ كَالْفَرَاشِ الْمَبْثُوثِ", translation: "The Day when people will be like scattered moths", transliteration: "Yawma yakoonu an-nasu kal-farashil-mabthooth"),

        // Surah 102 – At-Takathur
        QuranVerse(surahNumber: 102, verseNumber: 1, arabicText: "أَلْهَاكُمُ التَّكَاثُرُ", translation: "Competition in [worldly] increase diverts you", transliteration: "Alhakumu at-takathur"),
        QuranVerse(surahNumber: 102, verseNumber: 2, arabicText: "حَتَّى زُرْتُمُ الْمَقَابِرَ", translation: "Until you visit the graveyards", transliteration: "Hatta zurtumul-maqabir"),
        QuranVerse(surahNumber: 102, verseNumber: 3, arabicText: "كَلَّا سَوْفَ تَعْلَمُونَ", translation: "No! You will come to know", transliteration: "Kalla sawfa ta'lamoon"),
        QuranVerse(surahNumber: 102, verseNumber: 4, arabicText: "ثُمَّ كَلَّا سَوْفَ تَعْلَمُونَ", translation: "Then, no! You will come to know", transliteration: "Thumma kalla sawfa ta'lamoon"),

        // Surah 103 – Al-Asr
        QuranVerse(surahNumber: 103, verseNumber: 1, arabicText: "وَالْعَصْرِ", translation: "By time", transliteration: "Wal-'Asr"),
        QuranVerse(surahNumber: 103, verseNumber: 2, arabicText: "إِنَّ الْإِنسَانَ لَفِي خُسْرٍ", translation: "Indeed, mankind is in loss", transliteration: "Innal-insana lafi khusr"),
        QuranVerse(surahNumber: 103, verseNumber: 3, arabicText: "إِلَّا الَّذِينَ آمَنُوا", translation: "Except those who believe", transliteration: "Illa alladhina amanu"),
        QuranVerse(surahNumber: 103, verseNumber: 4, arabicText: "وَعَمِلُوا الصَّالِحَاتِ", translation: "And do righteous deeds", transliteration: "Wa 'amilus-salihati"),

        // Surah 104 – Al-Humazah
        QuranVerse(surahNumber: 104, verseNumber: 1, arabicText: "وَيْلٌ لِكُلِّ هُمَزَةٍ لُمَزَةٍ", translation: "Woe to every scorner and backbiter", transliteration: "Waylun likulli humazatin lumazah"),
        QuranVerse(surahNumber: 104, verseNumber: 2, arabicText: "الَّذِي جَمَعَ مَالًا وَعَدَّدَهُ", translation: "Who collects wealth and counts it", transliteration: "Alladhi jama'a malan wa 'addadah"),
        QuranVerse(surahNumber: 104, verseNumber: 4, arabicText: "كَلَّا ۖ لَيُنبَذَنَّ فِي الْحُطَمَةِ", translation: "No! He will surely be thrown into the Crusher [Hellfire]", transliteration: "Kalla layunbadhan fil-hutama"),

        // Surah 105 – Al-Fil
        QuranVerse(surahNumber: 105, verseNumber: 1, arabicText: "أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَابِ الْفِيلِ", translation: "Have you not seen how your Lord dealt with the companions of the elephant?", transliteration: "Alam tara kayfa fa'ala rabbuka bi as-habil-feel"),
        QuranVerse(surahNumber: 105, verseNumber: 2, arabicText: "أَلَمْ يَجْعَلْ كَيْدَهُمْ فِي تَضْلِيلٍ", translation: "Did He not make their plan go astray?", transliteration: "Alam yaj'al kaydahum fi tadlil"),
        QuranVerse(surahNumber: 105, verseNumber: 3, arabicText: "وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ", translation: "And He sent against them birds in flocks", transliteration: "Wa arsal 'alayhim tayran ababil"),
        QuranVerse(surahNumber: 105, verseNumber: 4, arabicText: "تَرْمِيهِم بِحِجَارَةٍ مِّن سِجِّيلٍ", translation: "Striking them with stones of baked clay", transliteration: "Tarmihim bihijaratin min sijjil"),

        // Surah 106 – Quraish
        QuranVerse(surahNumber: 106, verseNumber: 1, arabicText: "لِإِيلَافِ قُرَيْشٍ", translation: "For the accustomed security of the Quraysh", transliteration: "Li'ilafi Quraysh"),
        QuranVerse(surahNumber: 106, verseNumber: 2, arabicText: "إِيلَافِهِمْ رِحْلَةَ الشِّتَاءِ وَالصَّيْفِ", translation: "Their accustomed journey in winter and summer", transliteration: "Ilafihim rihlatash-shita'i was-sayf"),
        QuranVerse(surahNumber: 106, verseNumber: 3, arabicText: "فَلْيَعْبُدُوا رَبَّ هَذَا الْبَيْتِ", translation: "Let them worship the Lord of this House", transliteration: "Falyabudu rabbahadhal-bayt"),
        QuranVerse(surahNumber: 106, verseNumber: 4, arabicText: "الَّذِي أَطْعَمَهُمْ مِن جُوعٍ وَآمَنَهُمْ مِنْ خَوْفٍ", translation: "Who has fed them against hunger and secured them against fear", transliteration: "Alladhi at'amahum min ju'in wa amanahum min khawf"),

        // Surah 107 – Al-Ma'un
        QuranVerse(surahNumber: 107, verseNumber: 1, arabicText: "أَرَأَيْتَ الَّذِي يُكَذِّبُ بِالدِّينِ", translation: "Have you seen the one who denies the Recompense?", transliteration: "Ara'aytal-ladhi yukaththibu bid-din"),
        QuranVerse(surahNumber: 107, verseNumber: 2, arabicText: "فَذَلِكَ الَّذِي يَدُعُّ الْيَتِيمَ", translation: "That is the one who repulses the orphan", transliteration: "Fadhalikal-ladhi yadul-laytima"),
        QuranVerse(surahNumber: 107, verseNumber: 3, arabicText: "وَلَا يَحُضُّ عَلَى طَعَامِ الْمِسْكِينِ", translation: "And does not encourage feeding the poor", transliteration: "Wa la yahuddu 'ala ta'amil miskin"),
        QuranVerse(surahNumber: 107, verseNumber: 4, arabicText: "فَوَيْلٌ لِّلْمُصَلِّينَ", translation: "So woe to those who pray", transliteration: "Fawaylun lil-musallin"),

        // Surah 108 – Al-Kawthar
        QuranVerse(surahNumber: 108, verseNumber: 1, arabicText: "إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ", translation: "Indeed, We have granted you al-Kawthar", transliteration: "Inna a'tainaka al-kawthar"),
        QuranVerse(surahNumber: 108, verseNumber: 2, arabicText: "فَصَلِّ لِرَبِّكَ وَانْحَرْ", translation: "So pray to your Lord and sacrifice", transliteration: "Fasalli li rabbika wanhar"),
        QuranVerse(surahNumber: 108, verseNumber: 3, arabicText: "إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ", translation: "Indeed, your enemy is the one cut off", transliteration: "Inna shani'aka huwa al-abtar"),
        QuranVerse(surahNumber: 108, verseNumber: 4, arabicText: "", translation: "", transliteration: ""), // Surah has only 3 verses

        // Surah 109 – Al-Kafirun
        QuranVerse(surahNumber: 109, verseNumber: 1, arabicText: "قُلْ يَا أَيُّهَا الْكَافِرُونَ", translation: "Say, O disbelievers", transliteration: "Qul ya ayyuha al-kafirun"),
        QuranVerse(surahNumber: 109, verseNumber: 2, arabicText: "لَا أَعْبُدُ مَا تَعْبُدُونَ", translation: "I do not worship what you worship", transliteration: "La a'budu ma ta'budun"),
        QuranVerse(surahNumber: 109, verseNumber: 3, arabicText: "وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ", translation: "Nor do you worship what I worship", transliteration: "Wa la antum 'abiduna ma a'bud"),
        QuranVerse(surahNumber: 109, verseNumber: 4, arabicText: "وَلَا أَنَا عَابِدٌ مَّا عَبَدتُّمْ", translation: "Nor will I be a worshipper of what you worship", transliteration: "Wa la ana 'abidun ma 'abadtum"),

        // Surah 110 – An-Nasr
        QuranVerse(surahNumber: 110, verseNumber: 1, arabicText: "إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ", translation: "When the victory of Allah has come and the conquest", transliteration: "Iza jaa nasrullahi walfath"),
        QuranVerse(surahNumber: 110, verseNumber: 2, arabicText: "وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِي دِينِ اللَّهِ أَفْوَاجًا", translation: "And you see the people entering Allah’s religion in multitudes", transliteration: "Wa ra'aytan-nasa yadkhuluna fi dinillahi afwaja"),
        QuranVerse(surahNumber: 110, verseNumber: 3, arabicText: "فَسَبِّحْ بِحَمْدِ رَبِّكَ وَاسْتَغْفِرْهُ", translation: "Then exalt [Him] with praise of your Lord and ask forgiveness of Him", transliteration: "Fasabbih bihamdi rabbika wastaghfirhu"),
        QuranVerse(surahNumber: 110, verseNumber: 4, arabicText: "", translation: "", transliteration: ""), // Surah has only 3 verses

        // Surah 111 – Al-Masad
        QuranVerse(surahNumber: 111, verseNumber: 1, arabicText: "تَبَّتْ يَدَا أَبِي لَهَبٍ وَتَبَّ", translation: "May the hands of Abu Lahab be ruined, and ruined is he", transliteration: "Tabbat yada abee lahabin watabb"),
        QuranVerse(surahNumber: 111, verseNumber: 2, arabicText: "مَا أَغْنَىٰ عَنْهُ مَالُهُ وَمَا كَسَبَ", translation: "His wealth will not avail him or that which he gained", transliteration: "Ma aghna 'anhu maluhu wama kasab"),
        QuranVerse(surahNumber: 111, verseNumber: 3, arabicText: "سَيَصْلَى نَارًا ذَاتَ لَهَبٍ", translation: "He will [enter to] burn in a Fire of flame", transliteration: "Sayasla naran dhata lahab"),
        QuranVerse(surahNumber: 111, verseNumber: 4, arabicText: "وَامْرَأَتُهُ حَمَّالَةَ الْحَطَبِ", translation: "And his wife [as well]—carrier of firewood", transliteration: "Wa imra'atuhu hammalata al-hatab"),

        // Surah 112 – Al-Ikhlas
        QuranVerse(surahNumber: 112, verseNumber: 1, arabicText: "قُلْ هُوَ اللَّهُ أَحَدٌ", translation: "Say, He is Allah, [who is] One", transliteration: "Qul huwa Allahu ahad"),
        QuranVerse(surahNumber: 112, verseNumber: 2, arabicText: "اللَّهُ الصَّمَدُ", translation: "Allah, the Eternal Refuge", transliteration: "Allahu as-samad"),
        QuranVerse(surahNumber: 112, verseNumber: 3, arabicText: "لَمْ يَلِدْ وَلَمْ يُولَدْ", translation: "He neither begets nor is born", transliteration: "Lam yalid wa lam yulad"),
        QuranVerse(surahNumber: 112, verseNumber: 4, arabicText: "وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ", translation: "Nor is there to Him any equivalent", transliteration: "Wa lam yakun lahu kufuwan ahad"),

        // Surah 113 – Al-Falaq
        QuranVerse(surahNumber: 113, verseNumber: 1, arabicText: "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ", translation: "Say, I seek refuge in the Lord of daybreak", transliteration: "Qul a'udhu birabbil-falaq"),
        QuranVerse(surahNumber: 113, verseNumber: 2, arabicText: "مِن شَرِّ مَا خَلَقَ", translation: "From the evil of that which He created", transliteration: "Min sharri ma khalaq"),
        QuranVerse(surahNumber: 113, verseNumber: 3, arabicText: "وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ", translation: "And from the evil of darkness when it settles", transliteration: "Wa min sharri ghasqin iza waqab"),
        QuranVerse(surahNumber: 113, verseNumber: 4, arabicText: "وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ", translation: "And from the evil of the blowers in knots", transliteration: "Wa min sharri an-naffathati fil-'uqad"),

        // Surah 114 – An-Nas
        QuranVerse(surahNumber: 114, verseNumber: 1, arabicText: "قُلْ أَعُوذُ بِرَبِّ النَّاسِ", translation: "Say, I seek refuge in the Lord of mankind", transliteration: "Qul a'udhu birabbin-nas"),
        QuranVerse(surahNumber: 114, verseNumber: 2, arabicText: "مَلِكِ النَّاسِ", translation: "The Sovereign of mankind", transliteration: "Malikin-nas"),
        QuranVerse(surahNumber: 114, verseNumber: 3, arabicText: "إِلَٰهِ النَّاسِ", translation: "The God of mankind", transliteration: "Ilahin-nas"),
        QuranVerse(surahNumber: 114, verseNumber: 4, arabicText: "مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ", translation: "From the evil of the whisperer who withdraws", transliteration: "Min sharri al-waswasil-khannas")
    ]
}
