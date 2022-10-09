<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.xgodness.model.ResultRow" %>
<!DOCTYPE html>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="author" content="xGodness">
    <title>Assignment #2</title>
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

    <div id="canvas-container">
        <canvas id="canvas" width="400" height="400" style="border: 3px solid black; margin-top: 50px"></canvas>
    </div>

    <script src="javascript/graph.js"></script>

    <table id="frame-table" class="frame-table">

        <tr id="frame-table-input-row" class="frame-table-row">

            <td>
                <form action="${pageContext.request.contextPath}/main" method="post">
                <table id="input-table">
                    <tr>
                        <td id="input-table-x-cell">
                            <fieldset id="input-x-fieldset" class="input-field">
                                <legend><b>Parameter X:</b></legend>
                                <table id="input-x-table">
                                    <tr>
                                        <td>
                                            <input type="radio" id="input-x-neg-3" name="input-x-radio" value="-3" size="10">
                                            <label for="input-x-neg-3">-3</label>
                                        </td>
                                        <td>
                                            <input type="radio" id="input-x-neg-2" name="input-x-radio" value="-2" size="10">
                                            <label for="input-x-neg-2">-2</label>
                                        </td>
                                        <td>
                                            <input type="radio" id="input-x-neg-1" name="input-x-radio" value="-1" size="10">
                                            <label for="input-x-neg-1">-1</label>
                                        </td>
                                        <td>
                                            <input type="radio" id="input-x-0" name="input-x-radio" value="0" size="10">
                                            <label for="input-x-0">0</label>
                                        </td>
                                        <td>
                                            <input type="radio" id="input-x-1" name="input-x-radio" value="1" size="10">
                                            <label for="input-x-1">1</label>
                                        </td>
                                        <td>
                                            <input type="radio" id="input-x-2" name="input-x-radio" value="2" size="10">
                                            <label for="input-x-2">2</label>
                                        </td>
                                        <td>
                                            <input type="radio" id="input-x-3" name="input-x-radio" value="3" size="10">
                                            <label for="input-x-3">3</label>
                                        </td>
                                        <td>
                                            <input type="radio" id="input-x-4" name="input-x-radio" value="4" size="10">
                                            <label for="input-x-4">4</label>
                                        </td>
                                        <td>
                                            <input type="radio" id="input-x-5" name="input-x-radio" value="5" size="10">
                                            <label for="input-x-5">5</label>
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <fieldset id="input-y-fieldset" class="input-field">
                                <legend><b>Parameter Y:</b></legend>
                                <input type="text" id="input-y" size="10">
                            </fieldset>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <fieldset id="input-r-fieldset" class="input-field">
                                <legend><b>Parameter R:</b></legend>
                                <input type="text" id="input-r">
                            </fieldset>
                        </td>
                    </tr>

                    <tr>
                        <td>
                        <input type="submit" name="submit" value="submit"/>
<%--                            <button id="submit" class="button" role="button">Submit</button>--%>
<%--                            <script src="javascript/validation.js"></script>--%>
                        </td>
                    </tr>
                </table>
                </form>
            </td>

            <td id="input-table-message-cell">
                <fieldset id="message-fieldset" class="input-field">
                    <legend id="message-legend"><b>Message</b></legend>
                    <p id="message"></p>
                </fieldset>
            </td>

            <td id="input-table-res-cell">
<%--                <button id="button-clear" class="button" role="button" onclick="handleClear()">Clear</button>--%>

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
                    pageContext.setAttribute("variables", results);
                    </jsp:scriptlet>
                    <tbody>
                        <c:forEach var="results" items="${pageScope.variables}">
                            <tr class="results-row">
                                <td class="results-cell">
                                    <c:out value="${results.getX()}"/>
                                </td>
                                <td class="results-cell">
                                    <c:out value="${results.getY()}"/>
                                </td>
                                <td class="results-cell">
                                    <c:out value="${results.getR()}"/>
                                </td>
                                <td class="results-cell">
                                    <c:out value="${results.getTime()}"/>
                                </td>
                                <td class="results-cell">
                                    <c:out value="${results.isHit()}"/>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>

                </table>
            </td>
        </tr>
    </table>

    <script src="javascript/graph.js" onload="draw()"></script>



</body>

</html>