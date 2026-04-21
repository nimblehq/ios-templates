import Foundation

public enum UserDefaultsKey: String, CaseIterable, Sendable {

    case isOnboardingShowed = "UD_IS_ONBOARDING_SHOWED"
    
    // Rating Prompt
    case ratingPromptAppLaunchCount = "UD_RATING_PROMPT_APP_LAUNCH_COUNT"
    case ratingPromptFirstLaunchDate = "UD_RATING_PROMPT_FIRST_LAUNCH_DATE"
    case ratingPromptLastPromptedVersion = "UD_RATING_PROMPT_LAST_PROMPTED_VERSION"
    case ratingPromptSignificantEventCount = "UD_RATING_PROMPT_SIGNIFICANT_EVENT_COUNT"
}
