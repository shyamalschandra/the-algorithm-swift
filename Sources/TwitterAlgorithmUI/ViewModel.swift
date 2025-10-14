import Foundation
import SwiftUI
import TwitterAlgorithmCore
import TwitterAlgorithmML

// MARK: - Visualization View Model

@MainActor
public final class AlgorithmVisualizationViewModel: ObservableObject {
    @Published public var timeline = Timeline(
        id: UUID().uuidString,
        userId: "demo_user",
        tweets: []
    )
    
    @Published public var metrics = AlgorithmMetrics(
        totalCandidates: 0,
        filteredCandidates: 0,
        rankedCandidates: 0,
        processingTime: 0.0,
        memoryUsage: 0,
        cpuUsage: 0.0,
        cacheHitRate: 0.0,
        errorRate: 0.0
    )
    
    @Published public var isRunning = false
    @Published public var notifications: [TwitterAlgorithmCore.Notification] = []
    
    private let recommendationService: RecommendationService
    private var simulationTimer: Timer?
    private var featureExtractor = FeatureExtractor()
    
    public init() {
        self.recommendationService = RecommendationService()
    }
    
    public func startSimulation() {
        isRunning = true
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task {
                await self.updateSimulation()
            }
        }
    }
    
    public func stopSimulation() {
        isRunning = false
        simulationTimer?.invalidate()
        simulationTimer = nil
    }
    
    public func toggleSimulation() {
        if isRunning {
            stopSimulation()
        } else {
            startSimulation()
        }
    }
    
    public func refreshTimeline() async {
        do {
            let newTimeline = try await recommendationService.generateRecommendations(for: "demo_user")
            withAnimation(.easeInOut(duration: 0.5)) {
                self.timeline = newTimeline
            }
        } catch {
            print("Failed to refresh timeline: \(error)")
        }
    }
    
    public func getFeatureImportance() -> [FeatureImportance] {
        return [
            FeatureImportance(name: "Engagement", importance: 0.4),
            FeatureImportance(name: "Recency", importance: 0.3),
            FeatureImportance(name: "Relevance", importance: 0.2),
            FeatureImportance(name: "Diversity", importance: 0.1)
        ]
    }
    
    private func updateSimulation() async {
        do {
            // Generate new timeline
            let newTimeline = try await recommendationService.generateRecommendations(for: "demo_user")
            
            // Generate notifications
            let newNotifications = try await recommendationService.generateNotifications(for: "demo_user")
            
            // Update UI with animation
            withAnimation(.easeInOut(duration: 0.5)) {
                self.timeline = newTimeline
                self.notifications = newNotifications
                self.updateMetrics()
            }
            
        } catch {
            print("Simulation update failed: \(error)")
        }
    }
    
    private func updateMetrics() {
        metrics = AlgorithmMetrics(
            totalCandidates: Int.random(in: 100...1000),
            filteredCandidates: Int.random(in: 50...500),
            rankedCandidates: timeline.tweets.count,
            processingTime: Double.random(in: 0.1...2.0),
            memoryUsage: Int.random(in: 100...1000),
            cpuUsage: Double.random(in: 0.1...0.8),
            cacheHitRate: Double.random(in: 0.7...0.95),
            errorRate: Double.random(in: 0.0...0.05)
        )
    }
}

// MARK: - Demo Data Generator

public final class DemoDataGenerator: @unchecked Sendable {
    public static let shared = DemoDataGenerator()
    
    private init() {}
    
    public func generateSampleTweets(count: Int) -> [Tweet] {
        return (0..<count).map { index in
            Tweet(
                id: UUID().uuidString,
                authorId: "user_\(Int.random(in: 1...1000))",
                content: generateSampleContent(),
                retweetCount: Int.random(in: 0...1000),
                likeCount: Int.random(in: 0...10000),
                replyCount: Int.random(in: 0...500),
                quoteCount: Int.random(in: 0...100),
                hashtags: generateRandomHashtags(),
                mentions: generateRandomMentions()
            )
        }
    }
    
    public func generateSampleUsers(count: Int) -> [User] {
        return (0..<count).map { index in
            User(
                id: "user_\(index + 1)",
                username: "user\(index + 1)",
                displayName: "User \(index + 1)",
                verified: Bool.random(),
                followersCount: Int.random(in: 0...1000000),
                followingCount: Int.random(in: 0...10000),
                tweetsCount: Int.random(in: 0...100000)
            )
        }
    }
    
    public func generateSampleInteractions(count: Int) -> [Interaction] {
        return (0..<count).map { index in
            Interaction(
                id: UUID().uuidString,
                userId: "user_\(Int.random(in: 1...100))",
                tweetId: "tweet_\(Int.random(in: 1...1000))",
                type: InteractionType.allCases.randomElement() ?? .like,
                weight: Double.random(in: 0.1...1.0)
            )
        }
    }
    
    private func generateSampleContent() -> String {
        let templates = [
            "Just discovered this amazing new technology! 🚀",
            "Having a great day exploring the city 🌆",
            "The weather is perfect for a walk in the park 🌳",
            "Learning something new every day 📚",
            "Coffee and code - the perfect combination ☕️",
            "Excited about the future of AI and machine learning 🤖",
            "Beautiful sunset today 🌅",
            "Working on an interesting project 💻",
            "Meeting amazing people at the conference 👥",
            "Grateful for all the opportunities life brings 🙏"
        ]
        
        return templates.randomElement() ?? "Sample tweet content"
    }
    
    private func generateRandomHashtags() -> [String] {
        let hashtags = ["#technology", "#AI", "#machinelearning", "#swift", "#ios", "#programming", "#innovation", "#future"]
        let count = Int.random(in: 0...3)
        return Array(hashtags.shuffled().prefix(count))
    }
    
    private func generateRandomMentions() -> [String] {
        let mentions = ["@user1", "@user2", "@user3", "@user4", "@user5"]
        let count = Int.random(in: 0...2)
        return Array(mentions.shuffled().prefix(count))
    }
}

// MARK: - Animation Extensions

extension View {
    public func algorithmAnimation() -> some View {
        self
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
    }
    
    public func pulseAnimation() -> some View {
        self
            .scaleEffect(1.0)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: UUID()
            )
    }
}

// MARK: - Color Extensions

extension Color {
    public static let algorithmBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    public static let algorithmPurple = Color(red: 0.6, green: 0.2, blue: 1.0)
    public static let algorithmGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    public static let algorithmOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    public static let algorithmRed = Color(red: 1.0, green: 0.3, blue: 0.3)
}

// MARK: - Gradient Extensions

extension LinearGradient {
    public static let algorithmGradient = LinearGradient(
        colors: [.algorithmBlue, .algorithmPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let successGradient = LinearGradient(
        colors: [.algorithmGreen, .green],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let warningGradient = LinearGradient(
        colors: [.algorithmOrange, .orange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let errorGradient = LinearGradient(
        colors: [.algorithmRed, .red],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
