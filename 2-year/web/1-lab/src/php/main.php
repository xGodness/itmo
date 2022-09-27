<?php

    $pattern =
        "
        <!DOCTYPE html>
        <body>
        <table id='results-table'>
            <tr class='results-row'>
                <td class='results-cell'>
                    <p>%.2f</p>
                </td>
                <td class='results-cell'>
                    <p>%.2f</p>
                </td>
                <td class='results-cell'>
                    <p>%.2f</p>
                </td>
                <td class='results-cell'>
                    <p>%s</p>
                </td>
                <td class='results-cell'>
                    <p>%s</p>
                </td>
            </tr>
        </table>
        </body>
        ";

    function validate($x, $y, $r) {
        if (strlen($x) > 16 || strlen($y) > 16 || strlen($r) > 16) {
            return false;
        }
        if (!(is_numeric($x) && is_numeric($y) && is_numeric($r))) {
            return false;
        }
        if (!in_array($x, array(-3, -2, -1, 0, 1, 2, 3, 4, 5))) {
            return false;
        }
        if ($y <= -3 || $y >= 3) {
            return false;
        }
        if ($r <= 2 || $r >= 5) {
            return false;
        }
        return true;
    }

    function check($x, $y, $r) {
        if ($x >= 0) {
            if ($y >= 0) {
                return $x*$x + $y*$y <= $r*$r;
            }
            return $x <= $r && $y * 2 >= -$r;
        }
        if ($y >= 0) {
            return $y * 2 <= $x * 2 + $r;
        }
        return false;
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $json = file_get_contents('php://input');
        $data = json_decode($json, true);
        $x = $data["x"];
        $y = $data["y"];
        $r = $data["r"];
        if (!validate($x, $y, $r)) {
            $result = "Invalid input";
        }
        else {
            $result = (check($x, $y, $r) ? "Hit" : "Miss");
        }

        $timezone_offset_minutes = $data["timezone_offset_minutes"];
        $timezone_name = timezone_name_from_abbr("", $timezone_offset_minutes*60, false);
        date_default_timezone_set($timezone_name);

        echo sprintf($pattern, $x, $y, $r, date("d-m-Y H:i:s T"), $result);
    }

?>