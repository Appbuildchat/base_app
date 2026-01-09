from call_llm import call_llm

def generate_fsd_md(prd_content: str) -> str:
    """
    Generate a comprehensive Function Specification Document (FSD) for Flutter apps 
    based on the provided PRD (Product Requirements Document).
    """
    prompt = f"""
    [Objective]
    You are a senior technical specification writer and Flutter architect with expertise in mobile app development.
    Create a comprehensive, production-ready Function Specification Document (FSD) that serves as the definitive technical blueprint for developers, QA engineers, and project managers.

    [Critical Requirements]
    - Platform: Flutter mobile application (iOS & Android)
    - Backend: Exclusively Firebase ecosystem (Firestore, Authentication, Storage, etc.). No other custom backend APIs will be developed or integrated unless explicitly stated in the PRD for specific third-party services.
    - State Management: Simple state management using setState() and direct Firebase operations
    - Language: English (professional technical documentation style)
    - Format: Well-structured Markdown document
    - Audience: Development team, QA engineers, project managers

    [Analysis Instructions]
    FIRST, carefully analyze the provided PRD to understand:
    1. What type of app is being built (e.g., social media, e-commerce, productivity, etc.)
    2. Who are the target users and what are their main needs
    3. What are the core features and functionalities explicitly mentioned
    4. What kind of data will be stored and managed
    5. What are the key user workflows and interactions

    SECOND, determine what features to include:

    [MANDATORY BASIC FEATURES - Always Include These]
    These are essential for ANY mobile app and should be included even if not explicitly mentioned in the PRD:
    - User Authentication (Email/Password registration and login)
    - Password reset functionality
    - User profile management (view, edit profile information)
    - App settings and preferences
    - Basic navigation and routing
    - Loading states and error handling
    - Data validation and form handling
    - Local storage for user preferences (SharedPreferences only)
    - Network connectivity handling
    - Basic Firebase CRUD operations for core data entities
    - User session management
    - App lifecycle management (initialization, background/foreground)

    [OPTIONAL FEATURES - Only Include If Mentioned in PRD]
    These features should ONLY be included if explicitly mentioned or implied in the PRD:
    - Social logins (Google, Apple, Facebook, etc.)
    - Push notifications
    - Payment processing
    - Social sharing features
    - Real-time chat/messaging
    - Location services
    - Camera/photo features
    - File upload/download
    - Offline synchronization
    - Analytics tracking
    - Dark mode support
    - Biometric authentication
    - Third-party integrations

    [Document Structure - MANDATORY]
    Create a comprehensive FSD with the following detailed structure, but CUSTOMIZE all content based on the specific PRD provided:

    # [Extract App Name from PRD] - Function Specification Document (FSD)

    ## Document Information
    - **Document Version**: 1.0
    - **Last Updated**: [Current Date]
    - **Document Owner**: [Team/Organization]
    - **Review Status**: Draft/Under Review/Approved

    ## Table of Contents
    [Generate a detailed table of contents with section numbers]

    ## 1. Introduction
    ### 1.1 Document Purpose and Scope
    - Clear statement of what this document accomplishes
    - Who should use this document and how
    - Relationship to other project documents (PRD, technical design docs)

    ### 1.2 Application Overview
    [Extract from PRD: Specific app description, value proposition, target market]

    ### 1.3 Target Audience
    - Primary users: Flutter developers, backend developers
    - Secondary users: QA engineers, project managers, UI/UX designers
    - Stakeholders: Product managers, business analysts

    ### 1.4 Definitions, Acronyms, and Abbreviations
    - Technical terms specific to this project
    - Firebase terminology
    - Flutter/Dart concepts
    - Business domain terminology

    ## 2. System Overview
    ### 2.1 Product Vision and Strategic Goals
    - Long-term product vision
    - Business objectives this app serves
    - Success metrics and KPIs

    ### 2.2 User Personas and Characteristics
    - Detailed user personas with demographics, behaviors, needs
    - User journey mapping
    - Accessibility requirements

    ### 2.3 System Architecture Overview
    - High-level system architecture diagram description
    - Client-server interaction patterns (primarily with Firebase services)
    - **Third-party integrations overview**: Limited to essential services like Google Maps and Stripe (if applicable based on PRD), along with social login providers (Google, Apple). No other external APIs are planned unless explicitly specified in the PRD.

    ### 2.4 Technology Stack
    #### 2.4.1 Frontend Technology
  - **Flutter SDK version**: 3.32.4 (stable channel recommended)
  - **Dart language version**: 3.8.1
  - Key Flutter packages and dependencies
  - Development tools and IDE recommendations

    #### 2.4.2 Backend Technology
    - Firebase project configuration
    - Firebase services utilized (detailed list)
    - Authentication methods
    - Database structure approach

    ### 2.5 Development Constraints and Assumptions
    - Technical limitations
    - Business constraints
    - Timeline assumptions
    - Resource availability

    ### 2.6 State Management Strategy
    - Detailed explanation of setState-based local state management
    - Firebase real-time data binding patterns
    - State synchronization strategies
    - Error state handling approaches

    ## 3. Detailed Functional Requirements
    [IMPORTANT: Include specifications for:
    1. ALL mandatory basic features (authentication, profile management, settings, etc.) - even if not mentioned in PRD
    2. ALL specific features explicitly mentioned in the PRD
    3. ONLY optional features (social login, push notifications, etc.) that are mentioned in the PRD
    
    For EACH feature, create detailed specifications below using the actual feature names and requirements.]

    ### 3.1 Core Authentication Module (MANDATORY - Always Include)
    [Always include basic email/password authentication, password reset, session management]

    ### 3.2 User Profile Management Module (MANDATORY - Always Include)
    [Always include profile viewing, editing, basic user data management]

    ### 3.3 [Extract Specific Feature Modules from PRD]
    [For each unique feature/module mentioned in the PRD, create detailed specifications]
    #### 3.X.1 Module Overview
    - Purpose and business value
    - Integration points with other modules
    - Dependencies and prerequisites

    #### 3.X.2 [Specific Feature Name]
    **Business Context**
    - Why this feature exists
    - Business rules and logic
    - Success criteria

    **User Stories**
    - As a [user type], I want to [action] so that [benefit]
    - Acceptance criteria with Given/When/Then scenarios

    **Functional Specification**
    - **Inputs**:
      - User inputs (with validation rules)
      - System inputs (APIs, database)
      - External data sources
    - **Processing Logic**:
      - Step-by-step algorithmic flow
      - Firebase operations (Create/Read/Update/Delete)
      - Business rule implementation
      - Data validation and sanitization
      - State management flow
    - **Outputs**:
      - Success scenarios with expected results
      - Error scenarios with appropriate messaging
      - Side effects and state changes
    - **Pre-conditions**:
      - System state requirements
      - User authentication/authorization
      - Data prerequisites
    - **Post-conditions**:
      - System state after successful execution
      - Data consistency guarantees
      - Cleanup operations

    **Technical Implementation Details**
    - Flutter widgets and components involved
    - Firebase SDK methods and operations
    - HTTP/API calls if applicable
    - **SharedPreferences operations**
    - Navigation and routing changes

    **Error Handling and Edge Cases**
    - Network connectivity issues
    - Firebase operation failures
    - Input validation failures
    - Concurrent operation conflicts
    - Recovery mechanisms

    **Performance Considerations**
    - Expected load and usage patterns
    - Optimization strategies
    - Caching mechanisms
    - Resource management

    ## 4. Data Architecture and Models
    ### 4.1 Firebase Project Structure
    - Project configuration details
    - Environment setup (dev/staging/prod)
    - Security rule organization

    ### 4.2 Firebase Firestore Database Design (PRIMARY DATABASE)
    #### 4.2.1 Firestore Collection Architecture
    [For each collection:]
    
    **Collection: [collection_name]**
    - **Purpose**: Clear description of what this collection represents
    - **Access Patterns**: How data is typically queried and updated
    - **Scaling Considerations**: Expected growth and partitioning strategy

    **Document Structure:**
    | Field Name | Data Type | Required | Description | Validation Rules | Example Value |
    |------------|-----------|----------|-------------|------------------|---------------|
    | documentId | string | Yes | Unique document identifier | Auto-generated or custom format | "user_12345" |
    | field1 | string | Yes | Description | Max 100 chars, alphanumeric | "John Doe" |

    **Indexes Required:**
    - Composite indexes for complex queries
    - Single field indexes for sorting

    **Security Rules:**
    ```javascript
    // Example security rule structure
    allow read, write: if [conditions];
    ```

    ### 4.3 Firebase Authentication Setup
    - Authentication providers (email/password, Google, Apple, etc.)
    - User profile data structure
    - Role-based access control (if applicable)
    - Session management

    ### 4.4 Firebase Storage Configuration
    - File organization structure
    - Security rules for file access
    - Supported file types and size limits
    - CDN and caching strategies

    ### 4.5 Firebase Data Relationships and Referential Integrity
    - How Firestore collections relate to each other
    - Document reference patterns in Firestore
    - Data denormalization strategies for Firebase
    - Consistency maintenance approaches using Firebase transactions

    ## 5. User Interface Specifications
    ### 5.1 UI Architecture and Navigation
    - Navigation hierarchy and flow diagrams
    - Screen transition patterns
    - Deep linking requirements
    - Back button behavior

    ### 5.2 Screen-by-Screen Specifications
    [For each major screen:]
    
    **Screen: [Screen Name]**
    - **Purpose**: What the screen accomplishes
    - **Entry Points**: How users reach this screen
    - **UI Components**: Detailed widget hierarchy
    - **User Interactions**: All possible user actions
    - **Data Requirements**: What data is displayed and how it's fetched directly from Firebase (no mock data used).
    - **State Management**: Local state variables and their purposes, ensuring all data displayed is live from Firebase.
    - **Validation Rules**: Input validation and error messaging
    - **Accessibility**: Screen reader support, keyboard navigation
    - **Responsive Design**: Behavior on different screen sizes

    ### 5.3 UI/UX Design Principles
    - Design system adherence
    - Accessibility standards (WCAG compliance)
    - Internationalization support
    - Platform-specific design considerations

    ### 5.4 Error Handling and User Feedback
    - Loading states and progress indicators
    - Error message display patterns
    - Success feedback mechanisms
    - Offline state handling

    ## 6. Non-Functional Requirements
    ### 6.1 Performance Requirements
    - Screen transition performance
    - Network request timeout values
    - Memory usage constraints

    ### 6.2 Usability and Accessibility
    - User experience standards
    - Accessibility compliance levels
    - **Localization requirements**: The application will exclusively support English, regardless of regional locale. No other languages are required.
    - User testing criteria

    ### 6.3 Reliability and Availability
    - Uptime requirements
    - Error recovery mechanisms
    - Data backup and recovery
    - Disaster recovery planning

    ### 6.4 Scalability and Performance
    - Expected user load and growth
    - Database scaling strategies
    - CDN requirements
    - Monitoring and alerting

    ### 6.5 Maintainability
    - Code documentation standards
    - Testing requirements
    - Deployment procedures

    ## 7. Technical Implementation Guidelines
    ### 7.1 Development Environment Setup
    - Required Flutter SDK version and configuration
    - Development tools and IDE setup
    - Build system configuration
    - Debugging and profiling tools

    ### 7.2 Project Structure and Architecture
    - **Folder organization patterns**: The project will follow a domain-driven architecture. The core structure will be `lib/domain/`, where `domain` contains multiple domain-specific folders (e.g., `lib/domain/user`, `lib/domain/product`). Each domain folder will contain:
        - `entities/`: For entity models (e.g., `user_entity.dart`).
        - `functions/`: For domain-specific business logic functions (e.g., `user_service.dart`).
        - `presentations/`: For UI components related to the domain, further split into:
            - `screens/`: For full-page widgets (e.g., `user_profile_screen.dart`).
            - `widgets/`: For reusable UI widgets (e.g., `user_avatar_widget.dart`).
    - Code organization principles
    - Naming conventions
    - Import/export strategies

    ### 7.3 Firebase Integration Details
    - Firebase SDK configuration
    - Service initialization
    - Error handling patterns
    - Offline capability implementation

    ### 7.4 Code Quality and Standards
    - Linting rules and configurations
    - Code review checklists
    - Documentation requirements
    - Performance optimization guidelines

    ## 8. Deployment and DevOps
    ### 8.1 Build and Release Process
    - Build configuration for different environments
    - Automated testing in CI/CD pipeline
    - Code signing and app store preparation
    - Release versioning strategy

    ### 8.2 Maintenance and Support
    - Bug tracking and resolution process
    - Feature request handling
    - User support channels
    - Documentation maintenance

    ### 9.1 Planned Enhancements
    - Features planned for future releases
    - Technical debt considerations
    - Architecture evolution path

    ### 9.2 Explicitly Out of Scope
    - Features not included in current version
    - Platform limitations
    - Third-party integration limitations

    ## 10. Appendices
    ### Appendix A: API Reference
    ### Appendix B: Database Schema Details
    ### Appendix C: Technical Decision Records

    [Critical Writing Guidelines]
    - ANALYZE the PRD content first and extract specific app details, features, user types, and requirements
    - ALWAYS include all mandatory basic features (authentication, profile, settings, navigation, error handling) even if not mentioned in PRD
    - ONLY include optional features (social login, push notifications, payments, etc.) if explicitly mentioned in PRD
    - Be extremely detailed and specific - this document should enable a developer to implement THIS SPECIFIC APP
    - DO NOT use generic examples - everything should be tailored to the actual PRD content combined with mandatory app features
    - For each feature (both mandatory and PRD-specific), provide complete technical specifications
    - Include concrete examples, code snippets, and data structures specific to this app's needs
    - Make Firebase operations explicit (Firebase is the ONLY database - which Firestore collections, what queries, when to cache with SharedPreferences, etc.)
    - Include specific Flutter widgets and implementation patterns needed for this app's features
    - Provide measurable acceptance criteria based on the PRD requirements and standard app quality requirements
    - Consider the specific user personas and workflows described in the PRD while ensuring basic app functionality is covered
    - Remember: Firebase Firestore is the ONLY database, local storage is SharedPreferences only
    - ABSOLUTELY NO MOCK DATA should be assumed or described in any functional or UI specification; all data interactions must assume live Firebase data.

    [PRD Input]
    {prd_content}
    """

    messages = [
        {
            "role": "system", 
            "content": "You are an expert technical writer and Flutter architect specializing in comprehensive mobile app specifications. Create detailed, production-ready Function Specification Documents that enable teams to build high-quality Flutter applications."
        },
        {"role": "user", "content": prompt}
    ]

    response = call_llm(messages, model_type="5")
    return response.choices[0].message.content