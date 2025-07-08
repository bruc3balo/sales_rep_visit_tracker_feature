[![wakatime](https://wakatime.com/badge/user/e508bec6-f1ed-42e9-a365-8c4e69c8dd19/project/cd2034a0-28f1-4885-858e-a6c53b6d69ca.svg)](https://wakatime.com/badge/user/e508bec6-f1ed-42e9-a365-8c4e69c8dd19/project/cd2034a0-28f1-4885-858e-a6c53b6d69ca)

# sales_rep_visit_tracker_feature

Your task is to build a Visits Tracker feature for a Route-to-Market (RTM) Sales Force
Automation app. Design and structure your solution as though this feature is part of a
larger, scalable application.
The app should allow a sales rep to:

* Add a new visit by filling out a
 Nairobi form ([add_a_new_visit_use_case.dart](lib/domain/use_cases/visit/add_a_new_visit_use_case.dart))
* View a list of their customer
  visits [visit_list_of_past_visits_use_case.dart](lib/domain/use_cases/visit/visit_list_of_past_visits_use_case.dart)
* Track activities completed during the
  visit [visit_list_of_past_visits_use_case.dart](lib/domain/use_cases/visit/visit_list_of_past_visits_use_case.dart)
* View basic statistics related to their visits (e.g., how many
  completed) [count_visit_statistics_use_case.dart](lib/domain/use_cases/visit/count_visit_statistics_use_case.dart)
* Search or filter
  visits [visit_list_of_past_visits_use_case.dart](lib/domain/use_cases/visit/visit_list_of_past_visits_use_case.dart)

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

## Screenshots

# Screenshots

<details>
  <summary><strong>Visits</strong></summary>

- **Past Visits**
    - ![Dark Mode](./docs/images/past_visits_dark_mode.png "Past Visits Dark Mode")
    - ![Light Mode](./docs/images/past_visits_light_mode.png "Past Visits Light Mode")

- **Today's Visits**
    - ![Dark Mode](./docs/images/todays_visit_dark_mode.png "Today's Visit Dark Mode")
    - ![Light Mode](./docs/images/todays_visit_light_mode.png "Today's Visit Light Mode")

- **Filter Visits**
    - ![Dark Mode](./docs/images/filter_visit_dark_mode.png "Filter Visit Dark Mode")
    - ![Light Mode](./docs/images/filter_visits_light_mode.png "Filter Visits Light Mode")

- **Exit Confirmation**
    - ![Dark Mode](./docs/images/exit_confirmation.png "Exit Confirmation Dark Mode")
    - ![Light Mode](./docs/images/exit_confirmation_light_mode.png "Exit Confirmation Light Mode")
</details>

---

<details>
  <summary><strong>Activities</strong></summary>

- **Activity Heat Map**
    - ![Dark Mode](./docs/images/activity_heat_map_dark_mode.png "Activity Heat Map Dark Mode")
    - ![Light Mode](./docs/images/activity_heat_map_light_mode.png "Activity Heat Map Light Mode")

- **Top 5 Activities**
    - ![Dark Mode](./docs/images/top_5_activities_dark_mode.png "Top 5 Activities Dark Mode")
    - ![Light Mode](./docs/images/top_5_activities_light_mode.png "Top 5 Activities Light Mode")

- **New Activity**
    - ![Dark Mode](./docs/images/new_activity_dark_mode.png "New Activity Dark Mode")
    - ![Light Mode](./docs/images/new_activity_light_mode.png "New Activity Light Mode")

- **Delete/Edit Activity**
    - ![Delete - Dark](./docs/images/delete_activity_dark_mode.png "Delete Activity Dark Mode")
    - ![Delete Dismiss - Light](./docs/images/delete_dismiss_activity_light_mode.png "Delete Dismiss Activity Light Mode")
    - ![Deleting - Light](./docs/images/deleting_activity_light_mode.png "Deleting Activity Light Mode")
    - ![Edit Dismiss - Dark](./docs/images/edit_dismiss_activity_dark_mode.png "Edit Dismiss Activity Dark Mode")
    - ![Edit Dismiss - Light](./docs/images/edit_dismiss_activity_light_mode.png "Edit Dismiss Activity Light Mode")
</details>

---

<details>
  <summary><strong>Customers</strong></summary>

- **Customer Management (Light Mode)**
    - ![Video](./docs/images/customer_management_light_mode.mp4 "Customer Management Light Mode")

- **Customers**
    - ![Dark Mode](./docs/images/customers_dark_mode.png "Customers Dark Mode")
    - ![Light Mode](./docs/images/customers_light_mode.png "Customers Light Mode")

- **New Customer**
    - ![Dark Mode](./docs/images/new_customer_dark_mode.png "New Customer Dark Mode")
    - ![Light Mode](./docs/images/new_customer_light_mode.png "New Customer Light Mode")

- **Top 5 Customers**
    - ![Dark Mode](./docs/images/top_5_customers_dark_mode.png "Top 5 Customers Dark Mode")
    - ![Light Mode](./docs/images/top_5_customers_light_mode.png "Top 5 Customers Light Mode")
</details>

---

<details>
  <summary><strong>7-Day Summary</strong></summary>

- **Visits & Status**
    - ![Visits - Dark](./docs/images/last_7_days_visit_dark_mode.png "Last 7 Days Visit Dark Mode")
    - ![Status - Dark](./docs/images/last_7_days_status_dark_mode.png "Last 7 Days Status Dark Mode")
    - ![Status - Light](./docs/images/last_7_days_statys_light_mode.png "Last 7 Days Status Light Mode")
    - ![Summary - Light](./docs/images/last_7_days_light_mode.png "Last 7 Days Light Mode")

- **Total Status Distribution**
    - ![Dark Mode](./docs/images/total_status_distribution_dark_mode.png "Total Status Distribution Dark Mode")
    - ![Light Mode](./docs/images/total_status_distribution_light_mode.png "Total Status Distribution Light Mode")
</details>


# Dependencies used

1. Dart (3.6.0)
2. Flutter - Stable (3.27.1)
3. json_annotation: ^4.8.1
4. dio: ^5.8.0+1
5. get_it: ^8.0.3
6. hive: ^2.2.3
7. hive_flutter: ^1.1.0
8. crypto: ^3.0.6
9. intl: ^0.18.1
10. badges: ^3.1.2
11. connectivity_plus: ^6.0.3
12. internet_connection_checker: ^1.0.0+1
13. fluttertoast: ^8.2.10
14. fl_chart: ^0.71.0
15. dots_indicator: ^4.0.1
16. flutter_secure_storage: ^9.2.4
17. logger: ^2.6.0
18. flutter_native_splash: ^2.4.4
19. loading_animation_widget: ^1.3.0

# N/B
* Dart code indenture used is **150** **_Each line communicates something_**

# Design pattern

The chosen design pattern is MVVM due to it's robustness and ease of separation of UI and Data layer
The project is divided into 3 layers for clear separation of concerns and code reusability

# Building

## Code generation
```bash
    flutter pub run build_runner build --delete-conflicting-outputs
```

## Environment variables
Store values in a file and pass the path to --dart-define-from-file= or pass them from --dart-define
```properties
SUPABASE_BASE_URL=${SUPABASE_BASE_URL}
SUPABASE_API_KEY=${SUPABASE_API_KEY}
HIVE_ENCRYPTION_KEY_NAME=${HIVE_ENCRYPTION_KEY_NAME}
```

## Running
```bash
    flutter run --dart-define-from-file=.env
```

## Build apk
```bash
    flutter build apk --dart-define-from-file=.env
```

# CI/CD
Tag the commit
```bash
    git tag v.*
```

Push the tag to the remote repo
```bash
    git push origin v.*
```


Splash screen
```bash
  flutter pub run flutter_native_splash:create
```

Icons
```bash
  flutter pub run flutter_launcher_icons
```




