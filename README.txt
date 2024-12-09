Το project είναι μια εφαρμογή To-Do List API που βασίζεται σε AWS Lambda και Terraform. Η εφαρμογή επιτρέπει τη διαχείριση μιας λίστας εργασιών, παρέχοντας τη δυνατότητα στους χρήστες να προσθέτουν, να διαγράφουν και να βλέπουν τις εργασίες τους. Ο κώδικας της εφαρμογής βρίσκεται στο αρχείο app, όπου είναι γραμμένος σε Python και περιλαμβάνει endpoints για την αλληλεπίδραση με την εφαρμογή μέσω HTTP requests. Το Terraform αρχείο αναλαμβάνει τη δημιουργία της απαιτούμενης υποδομής στο AWS, όπως VPC, Subnet, Lambda λειτουργίες, API Gateway και IAM πολιτικές, αυτοματοποιώντας την ανάπτυξη της εφαρμογής και διασφαλίζοντας τη σωστή λειτουργία και ασφάλεια.

Το αρχείο της εφαρμογής(python) περιλαμβάνει τα παρακάτω endpoints:

GET /: Επιστρέφει ένα μενού επιλογών που εξηγεί τις λειτουργίες της εφαρμογής.
POST /add: Επιτρέπει την προσθήκη μιας νέας εργασίας στη λίστα. Αν το σώμα του αιτήματος (body) δεν περιέχει μια έγκυρη εργασία, επιστρέφεται μήνυμα σφάλματος.
DELETE /delete: Διαγράφει μια συγκεκριμένη εργασία από τη λίστα. Αν η εργασία δεν υπάρχει στη λίστα, επιστρέφεται μήνυμα σφάλματος.
GET /tasks: Επιστρέφει τη λίστα με όλες τις εργασίες που έχουν αποθηκευτεί.
GET /help: Παρέχει οδηγίες για τη χρήση του API και εξηγεί τις λειτουργίες των endpoints.
Κάθε endpoint επιστρέφει HTTP status codes και JSON απαντήσεις, διευκολύνοντας την αλληλεπίδραση με άλλες εφαρμογές.


Το Terraform αρχείο αναλαμβάνει τη δημιουργία της υποδομής στο AWS, περιλαμβάνοντας τα παρακάτω resources:

Δικτύωση (Networking):

VPC: Δημιουργείται ένα Virtual Private Cloud με CIDR block 10.0.0.0/16.
Subnet: Δημιουργείται ένα Public Subnet για να φιλοξενεί τους πόρους.
Internet Gateway: Συνδέει το VPC με το διαδίκτυο, εξασφαλίζοντας πρόσβαση για τα public resources.
Route Table: Προσθέτει routes για να κατευθύνει την κίνηση από το subnet προς το διαδίκτυο.
Lambda Function:

IAM Role: Δημιουργείται ρόλος για την εκτέλεση της Lambda λειτουργίας, με δικαιώματα για logging.
Lambda Function: Η Python εφαρμογή αρχειοθετείται (zip) και αναπτύσσεται ως Lambda Function.
Security Group: Παρέχει πρόσβαση HTTPS για την επικοινωνία.

API Gateway:

REST API: Δημιουργείται ένα API Gateway που διαχειρίζεται τα endpoints.
Methods και Integrations: Ορίζονται μέθοδοι (GET, POST, DELETE) και αντίστοιχες συνδέσεις (integrations) με τη Lambda λειτουργία.
Resource Policies: Εφαρμόζεται πολιτική που επιτρέπει τη δημόσια πρόσβαση στα API endpoints.
IAM Policies:

Δημιουργούνται πολιτικές για τη διαχείριση logs και την πρόσβαση στο API Gateway.
Remote State και Logging:

Περιλαμβάνονται resources για τη διαχείριση της κατάστασης (state) και των logs, διασφαλίζοντας ότι η υποδομή παρακολουθείται και είναι συνεπής.







This project is a To-Do List API based on AWS Lambda and Terraform. The application allows users to manage a task list by adding, deleting, and viewing tasks. The application logic is written in Python and is contained in the app file, which includes endpoints for interacting with the application via HTTP requests. The Terraform file handles the creation of the required AWS infrastructure, such as VPC, Subnet, Lambda functions, API Gateway, and IAM policies, automating the deployment and ensuring proper functionality and security.

The app file(python) includes the following endpoints:

GET /: Returns a menu with options explaining the application's features.
POST /add: Allows users to add a new task to the list. If the request body does not contain a valid task, an error message is returned.
DELETE /delete: Removes a specific task from the list. If the task does not exist, an error message is returned.
GET /tasks: Returns the current list of tasks.
GET /help: Provides instructions on how to use the API and explains the functionality of each endpoint.

The Terraform file handles the provisioning of the AWS infrastructure and includes the following resources:

Networking:

VPC: Creates a Virtual Private Cloud with a CIDR block of 10.0.0.0/16.
Subnet: Creates a Public Subnet to host the resources.
Internet Gateway: Connects the VPC to the internet, enabling public access to the resources.
Route Table: Adds routes to direct traffic from the subnet to the internet.
Lambda Function:

IAM Role: Creates a role for the Lambda function with permissions for logging.
Lambda Function: Packages the Python application into a zip file and deploys it as a Lambda function.
Security Group: Allows HTTPS traffic to facilitate communication.

API Gateway:

REST API: Creates an API Gateway that manages the endpoints.
Methods and Integrations: Defines methods (GET, POST, DELETE) and integrates them with the Lambda function.
Resource Policies: Applies policies to allow public access to the API endpoints.
IAM Policies:

Configures policies for managing logs and enabling access to the API Gateway.
Remote State and Logging:

Includes resources for managing state and logs to ensure consistent infrastructure monitoring.


