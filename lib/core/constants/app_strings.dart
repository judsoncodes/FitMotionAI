class AppStrings {
  // App Titles
  static const String appName = 'FitMotionAI';
  static const String appTagline = 'Adaptive AI Fitness & Recovery Coach';

  // Auth Screen Strings
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to access your personalized adaptive recovery plan';
  static const String signupTitle = 'Join FitMotionAI';
  static const String signupSubtitle = 'Start your intelligent bio-adaptive coaching plan';
  static const String emailLabel = 'Email Address';
  static const String passwordLabel = 'Password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String nameLabel = 'Full Name';
  static const String signInButton = 'Sign In';
  static const String signUpButton = 'Create Account';
  static const String googleSignInButton = 'Continue with Google';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';

  // Auth Error Messages
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorWeakPassword = 'Password must be at least 6 characters long.';
  static const String errorPasswordMismatch = 'Passwords do not match.';
  static const String errorWrongPassword = 'Incorrect password. Please try again.';
  static const String errorUserNotFound = 'No user account found with this email.';
  static const String errorEmailInUse = 'An account already exists with this email address.';
  static const String errorNetworkFailed = 'Network connection error. Please check your connection.';
  static const String errorGoogleSignInFailed = 'Google Sign-In was cancelled or failed.';
  static const String errorGenericAuth = 'Authentication failed. Please try again.';

  // Onboarding Strings
  static const String onboardingHeaderTitle = 'Personalize Your AI Coach';
  static const String onboardingStep1Title = 'Basic Metrics';
  static const String onboardingStep1Subtitle = 'We use these to calculate baseline metabolic rate & exercise loads.';
  static const String onboardingStep2Title = 'Fitness Level & Goal';
  static const String onboardingStep2Subtitle = 'Helps ACARE calibrate workout intensity & progression rate.';
  static const String onboardingStep3Title = 'Availability & Equipment';
  static const String onboardingStep3Subtitle = 'We fit your routines into your real-world schedule & gear.';
  static const String onboardingStep4Title = 'Health & Safety Disclosure';
  static const String onboardingStep4Subtitle = 'Transparent disclosure helps ACARE safely filter contraindicated exercises.';

  // Onboarding Fields
  static const String ageLabel = 'Age (years)';
  static const String sexLabel = 'Sex';
  static const String heightLabel = 'Height (cm)';
  static const String weightLabel = 'Weight (kg)';
  static const String daysPerWeekLabel = 'Days Available Per Week';
  static const String sessionDurationLabel = 'Session Duration (Minutes)';
  static const String equipmentLabel = 'Available Equipment';
  static const String hasInjuriesQuestion = 'Do you currently have any joint, muscle, or physical injuries?';
  static const String addInjuryButton = '+ Add Injury / Limitation';
  static const String bodyPartLabel = 'Body Part';
  static const String severityLabel = 'Severity';
  static const String injuryNotesLabel = 'Injury Notes / Specific Movement Triggers';
  static const String medicalConditionsLabel = 'Medical Conditions / Doctor Notes (Optional)';
  
  // Safety Microcopy
  static const String healthSafetyNoticeTitle = 'Why We Ask For Health Details';
  static const String healthSafetyNoticeBody = 
      'Your injury and medical history is kept strictly private. FitMotionAI uses structured injury data to automatically eliminate exercises that stress affected joints or muscles during active recovery sessions.';

  // Validation Error Strings
  static const String valAgeError = 'Please enter a valid age between 13 and 120.';
  static const String valHeightError = 'Please enter height between 100cm and 250cm.';
  static const String valWeightError = 'Please enter weight between 30kg and 300kg.';
  static const String valSelectSex = 'Please select a sex option.';
  static const String valSelectFitnessLevel = 'Please select your current fitness level.';
  static const String valSelectGoal = 'Please select a primary goal.';
  static const String valSelectEquipment = 'Please select at least one equipment option.';

  // Navigation & Buttons
  static const String nextStep = 'Next Step';
  static const String backStep = 'Back';
  static const String completeOnboarding = 'Complete Profile & Start Coaching';
}
