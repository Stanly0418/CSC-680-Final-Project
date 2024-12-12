# CSC-680-Final-Project
Project Goal
BillSplitter is an application designed to help users quickly calculate shared expenses for group dinners or trips. It aims to simplify the process of splitting bills and includes features for generating detailed expense summaries.
Features
Must-Have Features
Basic Bill Splitting

Input the total amount, number of people, and tip percentage.
Automatically calculate the amount each person should pay.
Rounding Option

Option to round up the calculated amount to the nearest whole number.
Local Data Storage

Save the last three bill-splitting records for future reference.
Nice-to-Have Features
Unequal Splitting

Allow users to input specific expenses for each person and calculate individual shares accordingly.
Summary Export

Generate and export detailed bill summaries in PDF or text file format.
Currency Conversion

Automatically convert bill amounts to different currencies using a free exchange rate API.
Technical Details
Development Tools
Xcode: For designing and building the application.
Swift: Main programming language.
CoreData: For storing bill records locally.
PDFKit (optional): To generate PDF summaries.
Page Design
Main Page

Input fields for total amount, number of people, and tip percentage.
A button to calculate the result and display the amount per person.
History Page

A list of the last three bill-splitting records, showing dates and amounts.
Details Page (optional)
