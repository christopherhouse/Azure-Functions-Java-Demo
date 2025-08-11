package com.christopherhouse.functions;

import java.util.*;

import com.christopherhouse.functions.models.*;
import com.christopherhouse.functions.services.OrderValidation;
import com.microsoft.azure.functions.annotation.*;
import com.microsoft.azure.functions.*;

public class ReceiveOrder{

    @FunctionName("ReceiveOrder")
    public HttpResponseMessage run(
            @HttpTrigger(name = "req", methods = {HttpMethod.POST}, authLevel = AuthorizationLevel.FUNCTION) HttpRequestMessage<Optional<String>> request,
            @ServiceBusQueueOutput(name = "message", queueName = "received-orders", connection = "ServiceBusConnection") OutputBinding<OrderRequest> message,
            final ExecutionContext context) {
        HttpResponseMessage response;
        context.getLogger().info("Received an order request.");

        String body = request.getBody().orElse("");
        OrderRequest orderRequest = null;
        try {
            orderRequest = new com.fasterxml.jackson.databind.ObjectMapper().readValue(body, OrderRequest.class);
            OrderConfirmation confirmation;

            if (orderIsValid(orderRequest)) {
                confirmation = createConfirmation(orderRequest);

                message.setValue(orderRequest);
            }
            else {
                confirmation = new OrderConfirmation();
                confirmation.setOrderStatus(OrderStatus.INVALID);
            }

            response = request.createResponseBuilder(HttpStatus.OK)
                    .body(confirmation)
                    .build();

        } catch (Exception e) {
            context.getLogger().severe("Failed to deserialize order request: " + e.getMessage());
            response = request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                    .body("Invalid order request format.")
                    .build();
        }

        return response;
    }

    private static boolean orderIsValid(OrderRequest orderRequest) {
        boolean result = false;

        try {
            result = OrderValidation.isValidOrder(orderRequest);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }

    private static OrderConfirmation createConfirmation(OrderRequest request) {
        double totalAmount = request.getLineItems().stream()
                .mapToDouble(LineItem::getTotalPrice)
                .sum();

        OrderConfirmation confirmation = new OrderConfirmation();
        confirmation.setOrderId(request.getOrderId());
        confirmation.setCustomerName(request.getCustomerName());
        confirmation.setCustomerEmail(request.getCustomerEmail());
        confirmation.setOrderDate(request.getOrderDate());
        confirmation.setOrderStatus(OrderStatus.RECEIVED);
        confirmation.setTotalAmount(totalAmount);

        return confirmation;
    }
}
