package com.xgodness.model;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import com.xgodness.util.Serializer;

@WebServlet(urlPatterns = "/check")
public class AreaCheckServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        Float x = getFloat(request.getParameter("x"));
        Float y = getFloat(request.getParameter("y"));
        Float r = getFloat(request.getParameter("r"));
        if (x != null && y != null && r != null && r > 0) {
            ResultRow resultRow = new ResultRow(
                    x,
                    y,
                    r,
                    isHit(x, y, r),
                    request.getParameter("time")
            );
            HttpSession session = request.getSession();
            String results = (String) session.getAttribute("results");
            results = (results == null)
                    ? "[%s]".formatted(Serializer.serialize(resultRow))
                    : results.substring(0, results.length() - 1) + ",%s]".formatted(Serializer.serialize(resultRow));
            session.setAttribute("results", results);

            request.getRequestDispatcher("/index.jsp").forward(request, response);
        }
    }

    private Float getFloat(String s) {
        try {
            return Float.parseFloat(s);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private boolean isHit(float x, float y, float r) {
        if (x >= 0) {
            if (y >= 0) {
                return x * x + y * y <= r * r;
            }
            return false;
        }
        if (y >= 0) {
            return x >= -r && y <= r;
        }
        return x >= -r && 2 * y >= -r;
    }

}
