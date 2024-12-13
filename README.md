# CSC-680-Final-Project

1. Project Overview
This project aims to create an intuitive iOS car-sharing application that connects guests seeking to rent vehicles with hosts offering their cars. The app will feature a streamlined registration process, efficient search and filter functionalities, and a secure booking and payment system to enhance user experience. All data will be managed locally using Core Data, eliminating the need for cloud services.

2. Objectives
Provide a Dual-Role Platform: Enable guests to easily find and rent suitable vehicles, while allowing hosts to list and manage their cars effortlessly.

Simplify User Interaction: Design an intuitive interface with straightforward operations to minimize the learning curve and improve efficiency.

Ensure Data Security: Implement robust security measures to protect user data and establish a trustworthy environment.

3. Core Features

3.1 User Roles

Guest:

Registration and Login: Facilitate a simple registration and login process, supporting email or social media accounts.

Search and Filter: Allow users to search for vehicles based on criteria such as brand, availability dates, price, and purpose.

Booking and Payment: Enable viewing of vehicle details, booking, and secure payment processing.

Profile Management: Provide options to view and update personal information and booking history.

Host:
Vehicle Management: Allow hosts to add, edit, and remove vehicle information, including photos, descriptions, availability dates, and pricing.

Booking Management: Enable hosts to view and manage booking requests from guests, with options to confirm or decline.

Profile Management: Provide options to view and update personal information and manage listed vehicles.


3.2 Additional Features

Rating System: Facilitate mutual ratings between guests and hosts to build trust.
Notification System: Send push notifications to inform users about booking statuses, messages, and other important updates.
Multilingual Support: Offer multiple language options to cater to a diverse user base.

4. Technical Specifications
Development Language: Swift.
Development Environment: Xcode.
Platform: iOS.
Data Storage:
User and Vehicle Information: Utilize Core Data for local storage.
User Settings: Store using UserDefaults.
Sensitive Information: Secure using Keychain.
Payment System: Integrate Apple Pay for online transactions.

5. Development Plan
Requirement Analysis: Identify all functional requirements and technical specifications.
Design: Create wireframes and UI designs for the application.
Frontend Development: Build the user interface and implement client-side functionalities using Swift and Xcode.
Data Storage Implementation: Set up Core Data to manage user and vehicle information locally.
Payment Integration: Incorporate Apple Pay to handle transactions.
Testing: Conduct comprehensive testing to ensure functionality, security, and performance.
Deployment: Launch the application on the App Store.
Maintenance: Provide ongoing support and updates as needed.
