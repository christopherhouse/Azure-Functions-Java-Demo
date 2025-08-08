package com.christopherhouse.functions;

import java.util.*;

import com.christopherhouse.functions.models.*;
import com.microsoft.azure.functions.annotation.AuthorizationLevel;
import com.microsoft.azure.functions.annotation.FunctionName;
import com.microsoft.azure.functions.annotation.HttpTrigger;
import com.microsoft.azure.functions.*;

public class ReceiveOrder{

    @FunctionName("ReceiveOrder")
    public HttpResponseMessage run(
            @HttpTrigger(name = "req", methods = {HttpMethod.POST}, authLevel = AuthorizationLevel.FUNCTION) HttpRequestMessage<Optional<String>> request,
            final ExecutionContext context) {
        HttpResponseMessage response;
        context.getLogger().info("Received an order request.");

        String body = request.getBody().orElse("");
        OrderRequest orderRequest = null;
        try {
            orderRequest = new com.fasterxml.jackson.databind.ObjectMapper().readValue(body, OrderRequest.class);
            response = request.createResponseBuilder(HttpStatus.OK)
                    .body(orderRequest)
                    .build();
        } catch (Exception e) {
            context.getLogger().severe("Failed to deserialize order request: " + e.getMessage());
            response = request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                    .body("Invalid order request format.")
                    .build();
        }

        return response;
    }
}
