<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$hostname = "localhost";
$database = "teleclinic";
$username = "root";
$password = "";

$response = new stdClass();
header('Content-Type: application/json');

if ($_SERVER["REQUEST_METHOD"] == "GET") {
    try {
        // Set the timezone to 'Asia/Kuala_Lumpur' (or the desired timezone)
        date_default_timezone_set('Asia/Kuala_Lumpur');

        $conn = new mysqli($hostname, $username, $password, $database);

        if ($conn->connect_error) {
            die("Connection failed: " . $conn->connect_error);
        }

       if (isset($_GET['specialistID'])) {
    $specialistID = $_GET['specialistID'];

    $nextDayDateTime = date('Y-m-d 00:00:00', strtotime('+1 day'));
    $stmt = $conn->prepare("SELECT consultation.*, patient.patientName
                           FROM consultation
                           INNER JOIN patient ON consultation.patientID = patient.patientID
                           WHERE consultation.specialistID = ?
                           AND consultation.consultationDateTime >= ?
                           ORDER BY consultation.consultationDateTime ASC");
    $stmt->bind_param("ss", $specialistID, $nextDayDateTime);


            if ($stmt->execute()) {
                $result = $stmt->get_result();
                $upcomingConsultations = array();

                while ($row = $result->fetch_assoc()) {
                    $upcomingConsultations[] = $row;
                }

                $response->data = $upcomingConsultations;
                $response->success = true;
            } else {
                $response->success = false;
                $response->error = "Error retrieving upcoming consultations: " . $stmt->error;
            }

            $stmt->close();
        } else {
            http_response_code(400);
            $response->error = "Specialist ID not provided";
        }

        $conn->close();

    } catch (Exception $ee) {
        http_response_code(500);
        $response->error = "Error occurred " . $ee->getMessage();
    }

    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit();
}
?>
