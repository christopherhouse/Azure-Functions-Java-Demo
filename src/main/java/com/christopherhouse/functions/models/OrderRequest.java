package com.christopherhouse.functions.models;

import java.util.ArrayList;
import java.util.List;

import jakarta.validation.constraints.*;

public class OrderRequest {

    @NotNull
    private String customerName;

    @NotNull
    @Email
    private String customerEmail;

    @NotNull
    private String customerPhone;

    @NotNull
    private String shippingAddress;

    private String billingAddress;

    @NotNull
    private String paymentMethod;

    @NotNull
    private String orderDate;

    @NotNull
    private String orderStatus;

    @NotNull
    private String orderId;

    @NotEmpty
    private List<LineItem> lineItems; // List of products in the order

    private String specialInstructions;

    @NotNull
    private String customerId; // Unique identifier for the customer

    public OrderRequest() {
        this.lineItems = new ArrayList<>();
    }

    public OrderRequest(String customerName, String customerEmail, String customerPhone, String shippingAddress,
                        String billingAddress, String paymentMethod, String orderDate, String orderStatus,
                        String orderId, List<LineItem> lineItems, String specialInstructions, String customerId) {
        this.customerName = customerName;
        this.customerEmail = customerEmail;
        this.customerPhone = customerPhone;
        this.shippingAddress = shippingAddress;
        this.billingAddress = billingAddress;
        this.paymentMethod = paymentMethod;
        this.orderDate = orderDate;
        this.orderStatus = orderStatus;
        this.orderId = orderId;
        this.lineItems = lineItems != null ? lineItems : new ArrayList<>();
        this.specialInstructions = specialInstructions;
        this.customerId = customerId;
    }

    public OrderRequest(String customerName, String customerEmail, String customerPhone, String shippingAddress,
                        String billingAddress, String paymentMethod, String orderDate, String orderStatus,
                        String orderId, String specialInstructions, String customerId) {
        this.customerName = customerName;
        this.customerEmail = customerEmail;
        this.customerPhone = customerPhone;
        this.shippingAddress = shippingAddress;
        this.billingAddress = billingAddress;
        this.paymentMethod = paymentMethod;
        this.orderDate = orderDate;
        this.orderStatus = orderStatus;
        this.orderId = orderId;
        this.specialInstructions = specialInstructions;
        this.customerId = customerId;

        this.lineItems = new ArrayList<>();
    }

    // Getters and Setters
    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerEmail() {
        return customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public String getBillingAddress() {
        return billingAddress;
    }

    public void setBillingAddress(String billingAddress) {
        this.billingAddress = billingAddress;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(String orderDate) {
        this.orderDate = orderDate;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public List<LineItem> getLineItems() {
        return lineItems;
    }

    public void setLineItems(List<LineItem> lineItems) {
        this.lineItems = lineItems;
    }

    public void AddLineItem(LineItem lineItem) {
        this.lineItems.add(lineItem);
    }

    public String getSpecialInstructions() {
        return specialInstructions;
    }

    public void setSpecialInstructions(String specialInstructions) {
        this.specialInstructions = specialInstructions;
    }

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

}
