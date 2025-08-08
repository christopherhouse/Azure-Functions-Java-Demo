package com.christopherhouse.functions.services;

import com.christopherhouse.functions.models.OrderRequest;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;

import java.util.Set;

public class OrderValidation {

    public static boolean isValidOrder(OrderRequest orderRequest) {
        boolean result = false;

        try {
            ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
            Validator validator = factory.getValidator();
            Set<ConstraintViolation<OrderRequest>> violations = validator.validate(orderRequest);

            if (!violations.isEmpty()) {
                for (ConstraintViolation<OrderRequest> violation : violations) {
                    System.out.println(violation.getPropertyPath() + ": " + violation.getMessage());
                }
            }
            else {
                result = true;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }
}
