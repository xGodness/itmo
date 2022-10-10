<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.xgodness.model.ResultRow" %>
<!DOCTYPE html>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="author" content="xGodness">
    <title>Results</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>

<body>
    <div id="page-header">
        <h1>♂Ass♂ignment #2</h1>
        <div id="info">
            <h2>Gotovko Alexey | P32101 | var. 1203</h2>
        </div>
        <hr>
    </div>

    <table id="results-table">
        <thead>
        <tr>
            <td class="results-cell">X</td>
            <td class="results-cell">Y</td>
            <td class="results-cell">R</td>
            <td class="results-cell">Time</td>
            <td class="results-cell">Hit or miss</td>
        </tr>
        </thead>

        <jsp:scriptlet>
                    String resultsJson = (String) request.getSession().getAttribute("results");
                    ResultRow[] results = new ResultRow[]{};
                    if (resultsJson != null && !resultsJson.isBlank()) {
                        results = com.xgodness.util.Serializer.deserializeRows(resultsJson);
                    }
                    pageContext.setAttribute("results", results);
                    </jsp:scriptlet>
        <tbody>
        <c:forEach var="res" items="${pageContext.getAttribute(\"results\")}">
            <tr class="results-row">
                <td class="results-cell">
                    <c:out value="${res.getX()}"/>
                </td>
                <td class="results-cell">
                    <c:out value="${res.getY()}"/>
                </td>
                <td class="results-cell">
                    <c:out value="${res.getR()}"/>
                </td>
                <td class="results-cell">
                    <c:out value="${res.getTime()}"/>
                </td>
                <td class="results-cell">
                    <c:out value="${res.isHit()}"/>
                </td>
            </tr>
        </c:forEach>
        </tbody>

    </table>