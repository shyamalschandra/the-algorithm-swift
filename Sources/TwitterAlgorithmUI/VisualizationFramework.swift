import SwiftUI
import TwitterAlgorithmCore
import Charts

// MARK: - SwiftUI Visualization Framework

/// Main visualization view for the Twitter algorithm
public struct AlgorithmVisualizationView: View {
    @StateObject private var viewModel = AlgorithmVisualizationViewModel()
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Tab selection
                tabSelectionView
                
                // Content
                TabView(selection: $selectedTab) {
                    // Timeline View
                    TimelineVisualizationView(viewModel: viewModel)
                        .tag(0)
                    
                    // Ranking View
                    RankingVisualizationView(viewModel: viewModel)
                        .tag(1)
                    
                    // Metrics View
                    MetricsVisualizationView(viewModel: viewModel)
                        .tag(2)
                    
                    // Network View
                    NetworkVisualizationView(viewModel: viewModel)
                        .tag(3)
                }
                // .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Not available on macOS
            }
            .background(
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .onAppear {
            viewModel.startSimulation()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "bird.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Twitter Algorithm")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    viewModel.toggleSimulation()
                }) {
                    Image(systemName: viewModel.isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            
            Text("Real-time Algorithm Visualization")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcon(for: index))
                            .font(.system(size: 16, weight: .medium))
                        
                        Text(tabTitle(for: index))
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == index ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray),
            alignment: .bottom
        )
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "list.bullet"
        case 1: return "chart.bar.fill"
        case 2: return "chart.line.uptrend.xyaxis"
        case 3: return "network"
        default: return "circle"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Timeline"
        case 1: return "Ranking"
        case 2: return "Metrics"
        case 3: return "Network"
        default: return ""
        }
    }
}

/// Timeline visualization view
public struct TimelineVisualizationView: View {
    @ObservedObject var viewModel: AlgorithmVisualizationViewModel
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.timeline.tweets) { candidate in
                    TweetCardView(candidate: candidate)
                        .transition(.opacity)
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refreshTimeline()
        }
    }
}

/// Individual tweet card view
public struct TweetCardView: View {
    let candidate: RecommendationCandidate
    @State private var isExpanded = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Circle()
                    .fill(scoreColor)
                    .frame(width: 8, height: 8)
                
                Text(candidate.reason.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Score: \(candidate.score, specifier: "%.2f")")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(scoreColor)
            }
            
            // Tweet content
            Text(candidate.tweet.content)
                .font(.body)
                .lineLimit(isExpanded ? nil : 3)
            
            // Engagement metrics
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text("\(candidate.tweet.likeCount)")
                        .font(.caption)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.2.squarepath")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text("\(candidate.tweet.retweetCount)")
                        .font(.caption)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("\(candidate.tweet.replyCount)")
                        .font(.caption)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Features (when expanded)
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Features:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 4) {
                        ForEach(Array(candidate.features.keys.sorted()), id: \.self) { key in
                            HStack {
                                Text(key)
                                    .font(.caption2)
                                Spacer()
                                Text("\(candidate.features[key] ?? 0, specifier: "%.2f")")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var scoreColor: Color {
        switch candidate.score {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .yellow
        case 0.4..<0.6: return .orange
        default: return .red
        }
    }
}

/// Ranking visualization view
public struct RankingVisualizationView: View {
    @ObservedObject var viewModel: AlgorithmVisualizationViewModel
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Score distribution chart
                scoreDistributionChart
                
                // Feature importance chart
                featureImportanceChart
                
                // Ranking factors
                rankingFactorsView
            }
            .padding()
        }
    }
    
    private var scoreDistributionChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Score Distribution")
                .font(.headline)
                .fontWeight(.semibold)
            
            Chart {
                ForEach(Array(viewModel.timeline.tweets.enumerated()), id: \.offset) { index, candidate in
                    BarMark(
                        x: .value("Position", index + 1),
                        y: .value("Score", candidate.score)
                    )
                    .foregroundStyle(scoreGradient(for: candidate.score))
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var featureImportanceChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Feature Importance")
                .font(.headline)
                .fontWeight(.semibold)
            
            let features = viewModel.getFeatureImportance()
            
            Chart(features, id: \.name) { feature in
                BarMark(
                    x: .value("Importance", feature.importance),
                    y: .value("Feature", feature.name)
                )
                .foregroundStyle(.blue.gradient)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var rankingFactorsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ranking Factors")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                RankingFactorCard(
                    title: "Engagement",
                    value: 0.4,
                    color: .blue
                )
                
                RankingFactorCard(
                    title: "Recency",
                    value: 0.3,
                    color: .green
                )
                
                RankingFactorCard(
                    title: "Relevance",
                    value: 0.2,
                    color: .orange
                )
                
                RankingFactorCard(
                    title: "Diversity",
                    value: 0.1,
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func scoreGradient(for score: Double) -> LinearGradient {
        let color: Color
        switch score {
        case 0.8...1.0: color = .green
        case 0.6..<0.8: color = .yellow
        case 0.4..<0.6: color = .orange
        default: color = .red
        }
        return LinearGradient(colors: [color.opacity(0.8), color], startPoint: .bottom, endPoint: .top)
    }
}

/// Ranking factor card
public struct RankingFactorCard: View {
    let title: String
    let value: Double
    let color: Color
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(value, specifier: "%.1f")")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            ProgressView(value: value, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

/// Metrics visualization view
public struct MetricsVisualizationView: View {
    @ObservedObject var viewModel: AlgorithmVisualizationViewModel
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Real-time metrics
                realTimeMetricsView
                
                // Performance metrics
                performanceMetricsView
                
                // Algorithm metrics
                algorithmMetricsView
            }
            .padding()
        }
    }
    
    private var realTimeMetricsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Real-time Metrics")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                MetricCard(
                    title: "Candidates",
                    value: "\(viewModel.metrics.totalCandidates)",
                    subtitle: "Total processed",
                    color: .blue
                )
                
                MetricCard(
                    title: "Filtered",
                    value: "\(viewModel.metrics.filteredCandidates)",
                    subtitle: "After filtering",
                    color: .orange
                )
                
                MetricCard(
                    title: "Final",
                    value: "\(viewModel.metrics.rankedCandidates)",
                    subtitle: "In timeline",
                    color: .green
                )
                
                MetricCard(
                    title: "Processing",
                    value: "\(String(format: "%.2f", viewModel.metrics.processingTime))s",
                    subtitle: "Time taken",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var performanceMetricsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Performance Metrics")
                .font(.headline)
                .fontWeight(.semibold)
            
            Chart {
                LineMark(
                    x: .value("Time", Date()),
                    y: .value("CPU Usage", viewModel.metrics.cpuUsage)
                )
                .foregroundStyle(.blue)
                
                LineMark(
                    x: .value("Time", Date()),
                    y: .value("Memory Usage", Double(viewModel.metrics.memoryUsage) / 1024)
                )
                .foregroundStyle(.green)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var algorithmMetricsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Algorithm Metrics")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                MetricRow(
                    title: "Cache Hit Rate",
                    value: "\(String(format: "%.1f", viewModel.metrics.cacheHitRate * 100))%",
                    color: .blue
                )
                
                MetricRow(
                    title: "Error Rate",
                    value: "\(String(format: "%.2f", viewModel.metrics.errorRate * 100))%",
                    color: .red
                )
                
                MetricRow(
                    title: "Memory Usage",
                    value: "\(viewModel.metrics.memoryUsage) MB",
                    color: .orange
                )
                
                MetricRow(
                    title: "CPU Usage",
                    value: "\(String(format: "%.1f", viewModel.metrics.cpuUsage * 100))%",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

/// Metric card component
public struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    public init(title: String, value: String, subtitle: String, color: Color) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.color = color
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

/// Metric row component
public struct MetricRow: View {
    let title: String
    let value: String
    let color: Color
    
    public var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}

/// Network visualization view
public struct NetworkVisualizationView: View {
    @ObservedObject var viewModel: AlgorithmVisualizationViewModel
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Network graph
                networkGraphView
                
                // User connections
                userConnectionsView
                
                // Influence network
                influenceNetworkView
            }
            .padding()
        }
    }
    
    private var networkGraphView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("User Network")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Simplified network visualization
            ZStack {
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(Color.blue.opacity(0.6))
                        .frame(width: 20, height: 20)
                        .position(
                            x: CGFloat.random(in: 50...300),
                            y: CGFloat.random(in: 50...200)
                        )
                }
            }
            .frame(height: 250)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var userConnectionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("User Connections")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(0..<10, id: \.self) { index in
                    HStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        
                        Text("User \(index + 1)")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(Int.random(in: 1...100)) connections")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var influenceNetworkView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Influence Network")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Shows how influence flows through the network")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Influence visualization
            HStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { index in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(influenceColor(for: index))
                            .frame(width: 30, height: 30)
                        
                        Text("\(index + 1)")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func influenceColor(for index: Int) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue]
        return colors[index % colors.count]
    }
}

/// Feature importance data structure
public struct FeatureImportance: Identifiable {
    public let id = UUID()
    public let name: String
    public let importance: Double
    
    public init(name: String, importance: Double) {
        self.name = name
        self.importance = importance
    }
}
