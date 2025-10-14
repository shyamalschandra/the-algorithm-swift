import SwiftUI
import TwitterAlgorithmCore
import TwitterAlgorithmUI

@main
struct TwitterAlgorithmCocoaApp: App {
    @StateObject private var viewModel = AlgorithmVisualizationViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .windowStyle(.automatic)
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    @EnvironmentObject var viewModel: AlgorithmVisualizationViewModel
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("🐦 Twitter Algorithm")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Swift 6.1+ Implementation")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Algorithm Visualization
                AlgorithmVisualizationView()
                    .environmentObject(viewModel)
                
                // Controls
                VStack(spacing: 15) {
                    HStack(spacing: 20) {
                        Button(action: {
                            viewModel.toggleSimulation()
                        }) {
                            HStack {
                                Image(systemName: viewModel.isRunning ? "pause.circle.fill" : "play.circle.fill")
                                Text(viewModel.isRunning ? "Stop Algorithm" : "Start Algorithm")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(viewModel.isRunning ? Color.red : Color.blue)
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.refreshTimeline()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Refresh")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .cornerRadius(8)
                        }
                    }
                    
                    // Status
                    HStack {
                        Circle()
                            .fill(viewModel.isRunning ? Color.green : Color.gray)
                            .frame(width: 12, height: 12)
                        
                        Text(viewModel.isRunning ? "Algorithm Running" : "Algorithm Stopped")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom)
            }
            .padding()
            .frame(minWidth: 800, minHeight: 600)
        }
    }
}

struct AlgorithmVisualizationView: View {
    @EnvironmentObject var viewModel: AlgorithmVisualizationViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Timeline
            VStack(alignment: .leading, spacing: 10) {
                Text("Timeline")
                    .font(.headline)
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.timeline.tweets, id: \.id) { candidate in
                            TweetCardView(tweet: candidate.tweet)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            
            // Metrics
            VStack(alignment: .leading, spacing: 10) {
                Text("Algorithm Metrics")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                    MetricCard(
                        title: "Candidates",
                        value: "\(viewModel.timeline.tweets.count)",
                        subtitle: "Processed",
                        color: .blue
                    )
                    
                    MetricCard(
                        title: "Engagement",
                        value: "85%",
                        subtitle: "Predicted",
                        color: .green
                    )
                    
                    MetricCard(
                        title: "Diversity",
                        value: "92%",
                        subtitle: "Score",
                        color: .orange
                    )
                }
            }
            
            // Feature Importance
            VStack(alignment: .leading, spacing: 10) {
                Text("Feature Importance")
                    .font(.headline)
                
                let features = viewModel.getFeatureImportance()
                ForEach(features, id: \.name) { feature in
                    HStack {
                        Text(feature.name)
                            .frame(width: 100, alignment: .leading)
                        
                        ProgressView(value: feature.importance)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        
                        Text("\(Int(feature.importance * 100))%")
                            .frame(width: 40, alignment: .trailing)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

struct TweetCardView: View {
    let tweet: Tweet
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tweet.content)
                    .font(.body)
                    .lineLimit(2)
                
                HStack {
                    Text("❤️ \(tweet.likeCount)")
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    Text("🔄 \(tweet.retweetCount)")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("💬 \(tweet.replyCount)")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("@\(tweet.authorId)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Score: 0.85")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
        .environmentObject(AlgorithmVisualizationViewModel())
}
