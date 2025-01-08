
# PickyEater Project Instructions

**PickyEater** is an iOS application designed to help users find and choose restaurants based on their dietary preferences and cravings.

## Overview

You are **Claude Sonnet 3.5**, an AI code editor tasked with building the **PickyEater** iOS app using **SwiftUI**. Your objective is to develop the app entirely by following the comprehensive documentation provided in the `docs/` directory. Ensure that all features are implemented accurately, efficiently, and adhere to best practices.

## Documentation Structure

Refer to the following documentation files for detailed information:

- **Product Requirements Document (PRD):** `[docs/prd.md](docs/prd.md)`  
  *Defines the app’s purpose, features, target audience, and success metrics.*

- **Frontend Documentation:** `[docs/frontend.md](docs/frontend.md)`  
  *Details the UI components, state management, and SwiftUI implementation.*

- **Backend Documentation:** `[docs/backend.md](docs/backend.md)`  
  *Covers API integrations, local data storage, authentication mechanisms, and subscription management.*

- **API Documentation:** `[docs/api.md](docs/api.md)`  
  *Explains interactions with third-party APIs like Yelp Fusion and affiliate programs.*

- **Database Schema Documentation:** `[docs/database-schema.md](docs/database-schema.md)`  
  *Describes data models and storage solutions using UserDefaults and Keychain.*

- **User Flow Documentation:** `[docs/user-flow.md](docs/user-flow.md)`  
  *Illustrates user journeys and interactions within the app.*

- **Third-Party Libraries Documentation:** `[docs/third-party-libraries.md](docs/third-party-libraries.md)`  
  *Lists and explains external libraries used in the project.*

- **Testing Plan:** `[docs/testing-plan.md](docs/testing-plan.md)`  
  *Outlines strategies for unit, integration, and UI testing.*

- **Code Documentation:** `[docs/code-documentation.md](docs/code-documentation.md)`  
  *Provides guidelines for inline comments and code structuring.*

- **DevOps Documentation:** `[docs/devops.md](docs/devops.md)`  
  *Details CI/CD pipelines, version control, and deployment strategies.*

## Development Workflow

1. **Planning:**
   - Review the **Product Requirements Document (PRD)** to understand project goals and features.
   - Refer to **User Flow Documentation** for user interaction guidelines and primary user journeys.

2. **Design:**
   - Follow **Frontend Documentation** for UI/UX standards and SwiftUI implementation.
   - Utilize **State Management Documentation** for managing app state effectively using SwiftUI and Combine.

3. **Implementation:**
   - Adhere to **Backend Documentation** for API integrations, data handling, and authentication.
   - Incorporate external tools and libraries as outlined in **Third-Party Libraries Documentation**.
   - Implement features according to the detailed plans in each documentation file.

4. **Testing:**
   - Develop tests as per the **Testing Plan** to ensure code quality and functionality.
   - Use **Code Documentation** guidelines to write maintainable and well-documented code.

5. **Deployment:**
   - Follow **DevOps Documentation** for setting up CI/CD pipelines, managing version control, and deploying builds.
   - Use **DevOps Documentation** to automate beta distributions and App Store submissions.

## AI Assistant Usage

When interacting with you, **Claude Sonnet 3.5**, follow these guidelines to ensure efficient and accurate assistance:

1. **Refer to Specific Documentation:**
   - **Example:** If assistance is needed with user authentication, refer to `docs/backend.md` under the "Authentication and Subscription Management" section.

2. **Structured Queries:**
   - Ask clear and concise questions related to specific components or issues.
   - Specify the relevant documentation reference if known to guide effective solutions.

3. **Continuous Reference:**
   - Continuously read and reference all documentation files in the `docs/` directory to inform responses and solutions.

4. **Sequential Assistance:**
   - Address one component or issue at a time, ensuring thorough and detailed assistance before moving to the next.

## Best Practices

- **Consistency:** Maintain uniform coding styles, naming conventions, and documentation standards across the project.

- **Security:** Prioritize data privacy and secure handling of user information, especially when dealing with authentication and preferences.

- **Efficiency:** Optimize performance by following outlined optimization strategies in the documentation.

- **Accessibility:** Ensure the app is accessible to all users by implementing recommended accessibility features such as Dynamic Type and VoiceOver compatibility.

- **Documentation Maintenance:** Keep all documentation up-to-date with any changes or new features added to the app.

## Troubleshooting

- **Common Issues:** Refer to specific sections in the documentation based on the problem area.
  - **Authentication Problems:** `docs/backend.md` under "Authentication and Subscription Management".
  - **API Integration Errors:** `docs/api.md`.
  - **UI Rendering Issues:** `docs/frontend.md`.

- **Error Messages:** Use **Error Handling Documentation** in both `docs/frontend.md` and `docs/backend.md` to interpret and resolve error messages.

- **Performance Bottlenecks:** Utilize strategies outlined in `docs/performance-optimization.md` to identify and fix performance issues.
