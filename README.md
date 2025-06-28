[![wakatime](https://wakatime.com/badge/user/e508bec6-f1ed-42e9-a365-8c4e69c8dd19/project/cd2034a0-28f1-4885-858e-a6c53b6d69ca.svg)](https://wakatime.com/badge/user/e508bec6-f1ed-42e9-a365-8c4e69c8dd19/project/cd2034a0-28f1-4885-858e-a6c53b6d69ca)

# sales_rep_visit_tracker_feature

Your task is to build a Visits Tracker feature for a Route-to-Market (RTM) Sales Force
Automation app. Design and structure your solution as though this feature is part of a
larger, scalable application.
The app should allow a sales rep to:

* Add a new visit by filling out a form ([add_a_new_visit_use_case.dart](lib/domain/use_cases/add_a_new_visit_use_case.dart))
* View a list of their customer visits [visit_list_of_past_visits_use_case.dart](lib/domain/use_cases/visit_list_of_past_visits_use_case.dart)
* Track activities completed during the visit [visit_list_of_past_visits_use_case.dart](lib/domain/use_cases/visit_list_of_past_visits_use_case.dart)
* View basic statistics related to their visits (e.g., how many completed) [count_visit_statistics_use_case.dart](lib/domain/use_cases/count_visit_statistics_use_case.dart)
* Search or filter visits [visit_list_of_past_visits_use_case.dart](lib/domain/use_cases/visit_list_of_past_visits_use_case.dart)

# License

This codebase is licensed under
the [Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)](https://creativecommons.org/licenses/by-nc-nd/4.0/)
license.

It is provided **strictly for the purpose of evaluation as part of a technical assessment**.

You may:

- View and review the code
- Share it for evaluation purposes

You may **not**:

- Use it for commercial or production purposes
- Modify and distribute it
- Deploy it in real-world systems

For other uses, please contact [**Bruce Omukoko**](https://bruc3balo.github.io)

# Dependencies used

1. Dart (3.6.0)
2. Flutter - Stable (3.27.1)

# Design pattern

The chosen design pattern is MVVM due to it's robustness and ease of separation of UI and Data layer
The project is divided into 3 layers for clear separation of concerns and code reusability


# Building
```bash
    flutter pub run build_runner build --delete-conflicting-outputs
```