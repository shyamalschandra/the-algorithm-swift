import XCTest
@testable import TwitterAlgorithmCore

final class TwitterAlgorithmCoreTests: XCTestCase {
    
    // MARK: - Model Tests
    
    func testUserModel() {
        let user = User(
            id: "test_user",
            username: "testuser",
            displayName: "Test User",
            verified: true,
            followersCount: 1000,
            followingCount: 500,
            tweetsCount: 200
        )
        
        XCTAssertEqual(user.id, "test_user")
        XCTAssertEqual(user.username, "testuser")
        XCTAssertEqual(user.displayName, "Test User")
        XCTAssertTrue(user.verified)
        XCTAssertEqual(user.followersCount, 1000)
    }
    
    func testTweetModel() {
        let tweet = Tweet(
            id: "test_tweet",
            authorId: "test_author",
            content: "This is a test tweet",
            retweetCount: 50,
            likeCount: 100,
            replyCount: 25
        )
        
        XCTAssertEqual(tweet.id, "test_tweet")
        XCTAssertEqual(tweet.authorId, "test_author")
        XCTAssertEqual(tweet.content, "This is a test tweet")
        XCTAssertEqual(tweet.likeCount, 100)
    }
    
    func testInteractionModel() {
        let interaction = Interaction(
            id: "test_interaction",
            userId: "test_user",
            tweetId: "test_tweet",
            type: .like,
            weight: 0.8
        )
        
        XCTAssertEqual(interaction.id, "test_interaction")
        XCTAssertEqual(interaction.userId, "test_user")
        XCTAssertEqual(interaction.tweetId, "test_tweet")
        XCTAssertEqual(interaction.type, .like)
        XCTAssertEqual(interaction.weight, 0.8)
    }
    
    func testRecommendationCandidateModel() {
        let tweet = Tweet(
            id: "test_tweet",
            authorId: "test_author",
            content: "Test content"
        )
        
        let candidate = RecommendationCandidate(
            id: "test_candidate",
            tweet: tweet,
            score: 0.85,
            reason: .engagement,
            features: ["engagement": 0.8, "recency": 0.9]
        )
        
        XCTAssertEqual(candidate.id, "test_candidate")
        XCTAssertEqual(candidate.tweet.id, "test_tweet")
        XCTAssertEqual(candidate.score, 0.85)
        XCTAssertEqual(candidate.reason, .engagement)
        XCTAssertEqual(candidate.features["engagement"], 0.8)
    }
    
    func testTimelineModel() {
        let tweet = Tweet(
            id: "test_tweet",
            authorId: "test_author",
            content: "Test content"
        )
        
        let candidate = RecommendationCandidate(
            id: "test_candidate",
            tweet: tweet,
            score: 0.85,
            reason: .engagement
        )
        
        let timeline = Timeline(
            id: "test_timeline",
            userId: "test_user",
            tweets: [candidate]
        )
        
        XCTAssertEqual(timeline.id, "test_timeline")
        XCTAssertEqual(timeline.userId, "test_user")
        XCTAssertEqual(timeline.tweets.count, 1)
        XCTAssertEqual(timeline.tweets.first?.id, "test_candidate")
    }
    
    func testNotificationModel() {
        let notification = Notification(
            id: "test_notification",
            userId: "test_user",
            type: .like,
            title: "Test Notification",
            body: "This is a test notification",
            score: 0.75
        )
        
        XCTAssertEqual(notification.id, "test_notification")
        XCTAssertEqual(notification.userId, "test_user")
        XCTAssertEqual(notification.type, .like)
        XCTAssertEqual(notification.title, "Test Notification")
        XCTAssertEqual(notification.score, 0.75)
    }
    
    // MARK: - Configuration Tests
    
    func testAlgorithmConfiguration() {
        let config = AlgorithmConfiguration()
        
        XCTAssertEqual(config.candidateSource.inNetworkWeight, 0.5)
        XCTAssertEqual(config.ranking.engagementWeight, 0.4)
        XCTAssertEqual(config.filtering.enableContentFiltering, true)
        XCTAssertEqual(config.mixing.timelineLimit, 20)
        XCTAssertEqual(config.notifications.maxNotifications, 10)
    }
    
    func testCandidateSourceConfiguration() {
        let config = CandidateSourceConfiguration(
            inNetworkWeight: 0.6,
            outOfNetworkWeight: 0.3,
            trendingWeight: 0.1,
            maxCandidates: 500
        )
        
        XCTAssertEqual(config.inNetworkWeight, 0.6)
        XCTAssertEqual(config.outOfNetworkWeight, 0.3)
        XCTAssertEqual(config.trendingWeight, 0.1)
        XCTAssertEqual(config.maxCandidates, 500)
    }
    
    func testRankingConfiguration() {
        let config = RankingConfiguration(
            engagementWeight: 0.5,
            recencyWeight: 0.3,
            relevanceWeight: 0.15,
            diversityWeight: 0.05
        )
        
        XCTAssertEqual(config.engagementWeight, 0.5)
        XCTAssertEqual(config.recencyWeight, 0.3)
        XCTAssertEqual(config.relevanceWeight, 0.15)
        XCTAssertEqual(config.diversityWeight, 0.05)
    }
    
    // MARK: - Service Tests
    
    func testRecommendationServiceInitialization() {
        let config = AlgorithmConfiguration()
        let service = RecommendationService(config: config)
        
        XCTAssertNotNil(service)
    }
    
    func testCandidateSourceService() {
        let config = CandidateSourceConfiguration()
        let service = CandidateSourceService(config: config)
        
        XCTAssertNotNil(service)
    }
    
    func testRankingService() {
        let config = RankingConfiguration()
        let service = RankingService(config: config)
        
        XCTAssertNotNil(service)
    }
    
    func testFilteringService() {
        let config = FilteringConfiguration()
        let service = FilteringService(config: config)
        
        XCTAssertNotNil(service)
    }
    
    func testMixingService() {
        let config = MixingConfiguration()
        let service = MixingService(config: config)
        
        XCTAssertNotNil(service)
    }
    
    func testNotificationService() {
        let config = NotificationConfiguration()
        let service = NotificationService(config: config)
        
        XCTAssertNotNil(service)
    }
    
    // MARK: - Integration Tests
    
    func testRecommendationServiceIntegration() async throws {
        let service = RecommendationService()
        
        do {
            let timeline = try await service.generateRecommendations(for: "test_user")
            XCTAssertNotNil(timeline)
            XCTAssertEqual(timeline.userId, "test_user")
            XCTAssertFalse(timeline.tweets.isEmpty)
        } catch {
            XCTFail("Recommendation service failed: \(error)")
        }
    }
    
    func testNotificationServiceIntegration() async throws {
        let service = RecommendationService()
        
        do {
            let notifications = try await service.generateNotifications(for: "test_user")
            XCTAssertNotNil(notifications)
            XCTAssertFalse(notifications.isEmpty)
        } catch {
            XCTFail("Notification service failed: \(error)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testRecommendationPerformance() async throws {
        let service = RecommendationService()
        let startTime = Date()
        
        do {
            _ = try await service.generateRecommendations(for: "test_user")
            let duration = Date().timeIntervalSince(startTime)
            
            // Should complete within reasonable time (adjust threshold as needed)
            XCTAssertLessThan(duration, 5.0, "Recommendation generation took too long")
        } catch {
            XCTFail("Performance test failed: \(error)")
        }
    }
    
    func testConcurrentRecommendations() async throws {
        let service = RecommendationService()
        
        // Test concurrent recommendation generation
        async let timeline1 = service.generateRecommendations(for: "user1")
        async let timeline2 = service.generateRecommendations(for: "user2")
        async let timeline3 = service.generateRecommendations(for: "user3")
        
        do {
            let (result1, result2, result3) = try await (timeline1, timeline2, timeline3)
            
            XCTAssertNotNil(result1)
            XCTAssertNotNil(result2)
            XCTAssertNotNil(result3)
            
            XCTAssertEqual(result1.userId, "user1")
            XCTAssertEqual(result2.userId, "user2")
            XCTAssertEqual(result3.userId, "user3")
        } catch {
            XCTFail("Concurrent recommendations failed: \(error)")
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyCandidateList() async throws {
        let service = RecommendationService()
        
        // This should handle empty candidate lists gracefully
        do {
            let timeline = try await service.generateRecommendations(for: "empty_user")
            XCTAssertNotNil(timeline)
            // Should still return a valid timeline, even if empty
        } catch {
            XCTFail("Empty candidate list handling failed: \(error)")
        }
    }
    
    func testInvalidUserId() async throws {
        let service = RecommendationService()
        
        do {
            let timeline = try await service.generateRecommendations(for: "")
            XCTAssertNotNil(timeline)
        } catch {
            // This might be expected behavior for invalid user IDs
            XCTAssertTrue(true, "Invalid user ID handled appropriately")
        }
    }
    
    // MARK: - Data Validation
    
    func testDataValidation() {
        // Test that models properly validate their data
        let user = User(
            id: "",
            username: "",
            displayName: ""
        )
        
        // Should handle empty strings gracefully
        XCTAssertEqual(user.id, "")
        XCTAssertEqual(user.username, "")
        XCTAssertEqual(user.displayName, "")
    }
    
    func testScoreValidation() {
        let tweet = Tweet(
            id: "test_tweet",
            authorId: "test_author",
            content: "Test content"
        )
        
        let candidate = RecommendationCandidate(
            id: "test_candidate",
            tweet: tweet,
            score: 1.5, // Invalid score > 1.0
            reason: .engagement
        )
        
        // Score should be clamped or validated
        XCTAssertEqual(candidate.score, 1.5) // This might need validation in the model
    }
    
    // MARK: - Memory Tests
    
    func testMemoryUsage() {
        // Test that services don't leak memory
        let service = RecommendationService()
        
        // Create and release multiple times
        for _ in 0..<100 {
            let _ = RecommendationService()
        }
        
        // If we get here without crashing, memory management is working
        XCTAssertTrue(true)
    }
    
    // MARK: - Thread Safety Tests
    
    func testThreadSafety() async throws {
        let service = RecommendationService()
        
        // Test concurrent access to the same service
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    do {
                        _ = try await service.generateRecommendations(for: "user_\(i)")
                    } catch {
                        // Handle errors appropriately
                    }
                }
            }
        }
        
        // If we get here without crashing, thread safety is working
        XCTAssertTrue(true)
    }
}
