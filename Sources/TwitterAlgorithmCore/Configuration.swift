import Foundation

// MARK: - Configuration Models

/// Main algorithm configuration
public struct AlgorithmConfiguration: Codable, Sendable {
    public let candidateSource: CandidateSourceConfiguration
    public let ranking: RankingConfiguration
    public let filtering: FilteringConfiguration
    public let mixing: MixingConfiguration
    public let notifications: NotificationConfiguration
    
    public init(
        candidateSource: CandidateSourceConfiguration = .default,
        ranking: RankingConfiguration = .default,
        filtering: FilteringConfiguration = .default,
        mixing: MixingConfiguration = .default,
        notifications: NotificationConfiguration = .default
    ) {
        self.candidateSource = candidateSource
        self.ranking = ranking
        self.filtering = filtering
        self.mixing = mixing
        self.notifications = notifications
    }
    
    public static let `default` = AlgorithmConfiguration()
}

/// Configuration for candidate sourcing
public struct CandidateSourceConfiguration: Codable, Sendable {
    public let inNetworkWeight: Double
    public let outOfNetworkWeight: Double
    public let trendingWeight: Double
    public let maxCandidates: Int
    public let enableRealTime: Bool
    public let cacheTimeout: TimeInterval
    
    public init(
        inNetworkWeight: Double = 0.5,
        outOfNetworkWeight: Double = 0.3,
        trendingWeight: Double = 0.2,
        maxCandidates: Int = 1000,
        enableRealTime: Bool = true,
        cacheTimeout: TimeInterval = 300
    ) {
        self.inNetworkWeight = inNetworkWeight
        self.outOfNetworkWeight = outOfNetworkWeight
        self.trendingWeight = trendingWeight
        self.maxCandidates = maxCandidates
        self.enableRealTime = enableRealTime
        self.cacheTimeout = cacheTimeout
    }
    
    public static let `default` = CandidateSourceConfiguration()
}

/// Configuration for ranking
public struct RankingConfiguration: Codable, Sendable {
    public let engagementWeight: Double
    public let recencyWeight: Double
    public let relevanceWeight: Double
    public let diversityWeight: Double
    public let enableMLRanking: Bool
    public let modelVersion: String
    
    public init(
        engagementWeight: Double = 0.4,
        recencyWeight: Double = 0.3,
        relevanceWeight: Double = 0.2,
        diversityWeight: Double = 0.1,
        enableMLRanking: Bool = true,
        modelVersion: String = "1.0"
    ) {
        self.engagementWeight = engagementWeight
        self.recencyWeight = recencyWeight
        self.relevanceWeight = relevanceWeight
        self.diversityWeight = diversityWeight
        self.enableMLRanking = enableMLRanking
        self.modelVersion = modelVersion
    }
    
    public static let `default` = RankingConfiguration()
}

/// Configuration for filtering
public struct FilteringConfiguration: Codable, Sendable {
    public let enableContentFiltering: Bool
    public let enableUserFiltering: Bool
    public let enableEngagementFiltering: Bool
    public let enableDiversityFiltering: Bool
    public let minEngagementThreshold: Int
    public let maxSimilarityThreshold: Double
    
    public init(
        enableContentFiltering: Bool = true,
        enableUserFiltering: Bool = true,
        enableEngagementFiltering: Bool = true,
        enableDiversityFiltering: Bool = true,
        minEngagementThreshold: Int = 0,
        maxSimilarityThreshold: Double = 0.8
    ) {
        self.enableContentFiltering = enableContentFiltering
        self.enableUserFiltering = enableUserFiltering
        self.enableEngagementFiltering = enableEngagementFiltering
        self.enableDiversityFiltering = enableDiversityFiltering
        self.minEngagementThreshold = minEngagementThreshold
        self.maxSimilarityThreshold = maxSimilarityThreshold
    }
    
    public static let `default` = FilteringConfiguration()
}

/// Configuration for mixing
public struct MixingConfiguration: Codable, Sendable {
    public let timelineLimit: Int
    public let enableDiversity: Bool
    public let enableRecency: Bool
    public let enableEngagement: Bool
    public let diversityThreshold: Double
    
    public init(
        timelineLimit: Int = 20,
        enableDiversity: Bool = true,
        enableRecency: Bool = true,
        enableEngagement: Bool = true,
        diversityThreshold: Double = 0.3
    ) {
        self.timelineLimit = timelineLimit
        self.enableDiversity = enableDiversity
        self.enableRecency = enableRecency
        self.enableEngagement = enableEngagement
        self.diversityThreshold = diversityThreshold
    }
    
    public static let `default` = MixingConfiguration()
}

/// Configuration for notifications
public struct NotificationConfiguration: Codable, Sendable {
    public let maxNotifications: Int
    public let enablePersonalized: Bool
    public let enableTrending: Bool
    public let enableEngagement: Bool
    public let minScoreThreshold: Double
    public let maxFrequency: TimeInterval
    
    public init(
        maxNotifications: Int = 10,
        enablePersonalized: Bool = true,
        enableTrending: Bool = true,
        enableEngagement: Bool = true,
        minScoreThreshold: Double = 0.3,
        maxFrequency: TimeInterval = 3600
    ) {
        self.maxNotifications = maxNotifications
        self.enablePersonalized = enablePersonalized
        self.enableTrending = enableTrending
        self.enableEngagement = enableEngagement
        self.minScoreThreshold = minScoreThreshold
        self.maxFrequency = maxFrequency
    }
    
    public static let `default` = NotificationConfiguration()
}
