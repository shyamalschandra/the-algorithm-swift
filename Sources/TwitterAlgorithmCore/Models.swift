import Foundation
import Crypto

// MARK: - Core Data Models

/// Represents a user in the Twitter algorithm
public struct User: Identifiable, Hashable, Codable {
    public let id: String
    public let username: String
    public let displayName: String
    public let verified: Bool
    public let followersCount: Int
    public let followingCount: Int
    public let tweetsCount: Int
    public let createdAt: Date
    public let profileImageURL: String?
    public let bio: String?
    
    public init(
        id: String,
        username: String,
        displayName: String,
        verified: Bool = false,
        followersCount: Int = 0,
        followingCount: Int = 0,
        tweetsCount: Int = 0,
        createdAt: Date = Date(),
        profileImageURL: String? = nil,
        bio: String? = nil
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.verified = verified
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.tweetsCount = tweetsCount
        self.createdAt = createdAt
        self.profileImageURL = profileImageURL
        self.bio = bio
    }
}

/// Represents a tweet/post in the algorithm
public struct Tweet: Identifiable, Hashable, Codable {
    public let id: String
    public let authorId: String
    public let content: String
    public let createdAt: Date
    public let retweetCount: Int
    public let likeCount: Int
    public let replyCount: Int
    public let quoteCount: Int
    public let isRetweet: Bool
    public let originalTweetId: String?
    public let mediaURLs: [String]
    public let hashtags: [String]
    public let mentions: [String]
    public let language: String?
    public let sentiment: Sentiment?
    
    public init(
        id: String,
        authorId: String,
        content: String,
        createdAt: Date = Date(),
        retweetCount: Int = 0,
        likeCount: Int = 0,
        replyCount: Int = 0,
        quoteCount: Int = 0,
        isRetweet: Bool = false,
        originalTweetId: String? = nil,
        mediaURLs: [String] = [],
        hashtags: [String] = [],
        mentions: [String] = [],
        language: String? = nil,
        sentiment: Sentiment? = nil
    ) {
        self.id = id
        self.authorId = authorId
        self.content = content
        self.createdAt = createdAt
        self.retweetCount = retweetCount
        self.likeCount = likeCount
        self.replyCount = replyCount
        self.quoteCount = quoteCount
        self.isRetweet = isRetweet
        self.originalTweetId = originalTweetId
        self.mediaURLs = mediaURLs
        self.hashtags = hashtags
        self.mentions = mentions
        self.language = language
        self.sentiment = sentiment
    }
}

/// Represents sentiment analysis results
public enum Sentiment: String, CaseIterable, Codable {
    case positive = "positive"
    case negative = "negative"
    case neutral = "neutral"
    case mixed = "mixed"
}

/// Represents user interactions with content
public struct Interaction: Identifiable, Hashable, Codable {
    public let id: String
    public let userId: String
    public let tweetId: String
    public let type: InteractionType
    public let timestamp: Date
    public let weight: Double
    
    public init(
        id: String,
        userId: String,
        tweetId: String,
        type: InteractionType,
        timestamp: Date = Date(),
        weight: Double = 1.0
    ) {
        self.id = id
        self.userId = userId
        self.tweetId = tweetId
        self.type = type
        self.timestamp = timestamp
        self.weight = weight
    }
}

/// Types of user interactions
public enum InteractionType: String, CaseIterable, Codable {
    case like = "like"
    case retweet = "retweet"
    case reply = "reply"
    case quote = "quote"
    case bookmark = "bookmark"
    case share = "share"
    case view = "view"
    case click = "click"
    case dwell = "dwell"
    case scroll = "scroll"
}

/// Represents a recommendation candidate
public struct RecommendationCandidate: Identifiable, Hashable, Codable {
    public let id: String
    public let tweet: Tweet
    public let score: Double
    public let reason: RecommendationReason
    public let features: [String: Double]
    public let timestamp: Date
    
    public init(
        id: String,
        tweet: Tweet,
        score: Double,
        reason: RecommendationReason,
        features: [String: Double] = [:],
        timestamp: Date = Date()
    ) {
        self.id = id
        self.tweet = tweet
        self.score = score
        self.reason = reason
        self.features = features
        self.timestamp = timestamp
    }
}

/// Reasons for recommendations
public enum RecommendationReason: String, CaseIterable, Codable {
    case inNetwork = "in_network"
    case outOfNetwork = "out_of_network"
    case trending = "trending"
    case similarUsers = "similar_users"
    case topicInterest = "topic_interest"
    case recency = "recency"
    case engagement = "engagement"
    case socialProof = "social_proof"
    case diversity = "diversity"
}

/// Represents a timeline
public struct Timeline: Identifiable, Codable {
    public let id: String
    public let userId: String
    public let tweets: [RecommendationCandidate]
    public let createdAt: Date
    public let algorithm: String
    public let version: String
    
    public init(
        id: String,
        userId: String,
        tweets: [RecommendationCandidate],
        createdAt: Date = Date(),
        algorithm: String = "for_you",
        version: String = "1.0"
    ) {
        self.id = id
        self.userId = userId
        self.tweets = tweets
        self.createdAt = createdAt
        self.algorithm = algorithm
        self.version = version
    }
}

/// Represents a notification
public struct Notification: Identifiable, Codable {
    public let id: String
    public let userId: String
    public let type: NotificationType
    public let title: String
    public let body: String
    public let tweetId: String?
    public let authorId: String?
    public let createdAt: Date
    public let priority: NotificationPriority
    public let score: Double
    
    public init(
        id: String,
        userId: String,
        type: NotificationType,
        title: String,
        body: String,
        tweetId: String? = nil,
        authorId: String? = nil,
        createdAt: Date = Date(),
        priority: NotificationPriority = .medium,
        score: Double = 0.0
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.body = body
        self.tweetId = tweetId
        self.authorId = authorId
        self.createdAt = createdAt
        self.priority = priority
        self.score = score
    }
}

/// Types of notifications
public enum NotificationType: String, CaseIterable, Codable {
    case like = "like"
    case retweet = "retweet"
    case reply = "reply"
    case mention = "mention"
    case follow = "follow"
    case trending = "trending"
    case breaking = "breaking"
    case personalized = "personalized"
}

/// Notification priority levels
public enum NotificationPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
}

/// Represents algorithm metrics
public struct AlgorithmMetrics: Codable {
    public let totalCandidates: Int
    public let filteredCandidates: Int
    public let rankedCandidates: Int
    public let processingTime: TimeInterval
    public let memoryUsage: Int
    public let cpuUsage: Double
    public let cacheHitRate: Double
    public let errorRate: Double
    public let timestamp: Date
    
    public init(
        totalCandidates: Int,
        filteredCandidates: Int,
        rankedCandidates: Int,
        processingTime: TimeInterval,
        memoryUsage: Int,
        cpuUsage: Double,
        cacheHitRate: Double,
        errorRate: Double,
        timestamp: Date = Date()
    ) {
        self.totalCandidates = totalCandidates
        self.filteredCandidates = filteredCandidates
        self.rankedCandidates = rankedCandidates
        self.processingTime = processingTime
        self.memoryUsage = memoryUsage
        self.cpuUsage = cpuUsage
        self.cacheHitRate = cacheHitRate
        self.errorRate = errorRate
        self.timestamp = timestamp
    }
}
