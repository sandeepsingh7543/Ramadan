import SwiftUI

struct TicketsView: View {
    @EnvironmentObject var movieManager: MovieManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Content
            if movieManager.tickets.isEmpty {
                emptyStateView
            } else {
                ticketsContent
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("My Tickets")
                    .font(.system(size: 32, weight: .ultraLight, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(movieManager.tickets.count) tickets booked")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "ticket.fill")
                .font(.system(size: 24))
                .foregroundColor(.pink)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var ticketsContent: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(movieManager.tickets.sorted(by: { $0.showDate > $1.showDate })) { ticket in
                    TicketCard(ticket: ticket)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "ticket")
                .font(.system(size: 60, weight: .ultraLight))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No tickets booked")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Book tickets from movie details")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
            
            Spacer()
        }
    }
}

struct TicketCard: View {
    let ticket: MovieTicket
    
    var body: some View {
        VStack(spacing: 0) {
            // Ticket Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticket.movieTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(ticket.theater)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(ticket.price, specifier: "%.2f")")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("TICKET")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [.pink, .pink.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            // Perforated Line
            HStack(spacing: 0) {
                ForEach(0..<20, id: \.self) { _ in
                    Circle()
                        .fill(.white.opacity(0.4))
                        .frame(width: 4, height: 4)
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 8, height: 1)
                }
            }
            .padding(.vertical, 2)
            .background(.pink.opacity(0.9))
            
            // Ticket Details
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DATE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(ticket.showDate, style: .date)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("TIME")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(ticket.showTime)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("SEAT")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(ticket.seatNumber)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                // QR Code Placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.2))
                    .frame(height: 60)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Scan at theater")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    )
                
                Text("Booked on \(ticket.bookingDate, style: .date)")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [.pink.opacity(0.8), .pink.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    TicketsView()
        .environmentObject(MovieManager())
}
