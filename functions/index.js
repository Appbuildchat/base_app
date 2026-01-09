const {onCall} = require("firebase-functions/v2/https");
// const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Stripe secret key from environment (set via: firebase functions:config:set stripe.secret_key="sk_...")
// Or use .env file with functions:secrets for production
const STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY || functions.config().stripe?.secret_key || "";
const stripe = require("stripe")(STRIPE_SECRET_KEY);
// Initialize Firebase Admin SDK
admin.initializeApp();

/**
 * Cloud Function to check email availability
 * Function checks if an email is already registered in the users collection
 */
exports.checkEmailAvailability = onCall(async (request) => {
  try {
    const {email} = request.data;

    // Validate input
    if (!email || typeof email !== "string") {
      logger.warn("Invalid email provided:", email);
      throw new Error("Email is required and must be a string");
    }

    // Normalize email to lowercase
    const normalizedEmail = email.toLowerCase().trim();

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(normalizedEmail)) {
      logger.warn("Invalid email format:", normalizedEmail);
      throw new Error("Invalid email format");
    }

    logger.info("Checking email availability for:", normalizedEmail);

    // Query Firestore for existing email
    const db = admin.firestore();
    const userSnapshot = await db
        .collection("users")
        .where("email", "==", normalizedEmail)
        .limit(1)
        .get();
    const isAvailable = userSnapshot.empty;
    logger.info("Email availability result:", {
      email: normalizedEmail,
      available: isAvailable,
      existingCount: userSnapshot.size,
    });
    return {
      success: true,
      available: isAvailable,
      email: normalizedEmail,
      message: isAvailable ? "Email is available" : "Email is already in use",
    };
  } catch (error) {
    logger.error("Error checking email availability:", error);
    return {
      success: false,
      available: false,
      error: error.message,
    };
  }
});

/**
 * Cloud Function to create a Stripe Payment Intent
 */
exports.createPaymentIntent = onCall(async (request) => {
  try {
    const {productId, amount, currency = "usd", userId, metadata = {}} = request.data;

    // Validate auth
    if (!request.auth) {
      logger.warn("Unauthenticated request to createPaymentIntent");
      throw new Error("Authentication required");
    }

    // Validate input
    if (!productId || !amount || !userId) {
      logger.warn("Missing required parameters:", {productId, amount, userId});
      throw new Error("Product ID, amount, and user ID are required");
    }

    if (amount < 50) { // Minimum 50 cents
      throw new Error("Amount must be at least 50 cents");
    }

    logger.info("Creating payment intent:", {
      productId,
      amount,
      currency,
      userId,
      authUid: request.auth.uid,
    });

    // Create payment intent with Stripe
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount), // Ensure integer
      currency: currency.toLowerCase(),
      automatic_payment_methods: {
        enabled: true,
      },
      metadata: {
        productId,
        userId,
        ...metadata,
      },
    });

    logger.info("Payment intent created successfully:", {
      paymentIntentId: paymentIntent.id,
      clientSecret: paymentIntent.client_secret,
      amount: paymentIntent.amount,
      status: paymentIntent.status,
    });

    return {
      success: true,
      paymentIntent: {
        id: paymentIntent.id,
        paymentIntentId: paymentIntent.id,
        clientSecret: paymentIntent.client_secret,
        client_secret: paymentIntent.client_secret,
        amount: paymentIntent.amount,
        currency: paymentIntent.currency,
        status: paymentIntent.status,
        metadata: paymentIntent.metadata,
      },
    };
  } catch (error) {
    logger.error("Error creating payment intent:", error);
    return {
      success: false,
      error: error.type || "PAYMENT_INTENT_CREATION_FAILED",
      message: error.message,
    };
  }
});

/**
 * Cloud Function to verify a Payment Intent
 */
exports.verifyPaymentIntent = onCall(async (request) => {
  try {
    const {paymentIntentId} = request.data;

    // Validate auth
    if (!request.auth) {
      logger.warn("Unauthenticated request to verifyPaymentIntent");
      throw new Error("Authentication required");
    }

    // Validate input
    if (!paymentIntentId) {
      logger.warn("Missing payment intent ID");
      throw new Error("Payment Intent ID is required");
    }

    logger.info("Verifying payment intent:", {
      paymentIntentId,
      authUid: request.auth.uid,
    });

    // Retrieve payment intent from Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    // Check for refund information if charge exists
    let amountRefunded = 0;
    let refundDetails = null;
    if (paymentIntent.latest_charge) {
      try {
        const charge = await stripe.charges.retrieve(paymentIntent.latest_charge);
        amountRefunded = charge.amount_refunded;
        // Get refund details if refunded
        if (amountRefunded > 0) {
          const refunds = await stripe.refunds.list({
            charge: paymentIntent.latest_charge,
            limit: 10,
          });
          refundDetails = refunds.data;
        }
        logger.info("Charge details retrieved:", {
          chargeId: charge.id,
          amountRefunded: amountRefunded,
          refundCount: refundDetails ? refundDetails.length : 0,
        });
      } catch (chargeError) {
        logger.warn("Could not retrieve charge details:", {
          chargeId: paymentIntent.latest_charge,
          error: chargeError.message,
        });
      }
    }

    logger.info("Payment intent verification result:", {
      paymentIntentId: paymentIntent.id,
      status: paymentIntent.status,
      amount: paymentIntent.amount,
      amountRefunded: amountRefunded,
      latestCharge: paymentIntent.latest_charge,
    });

    return {
      success: true,
      paymentIntent: {
        id: paymentIntent.id,
        paymentIntentId: paymentIntent.id,
        clientSecret: paymentIntent.client_secret,
        client_secret: paymentIntent.client_secret,
        amount: paymentIntent.amount,
        currency: paymentIntent.currency,
        status: paymentIntent.status,
        amount_refunded: amountRefunded,
        refund_details: refundDetails,
        metadata: {
          ...paymentIntent.metadata,
          charge_id: paymentIntent.latest_charge || null,
          amount_refunded: amountRefunded,
        },
        latest_charge: paymentIntent.latest_charge,
      },
    };
  } catch (error) {
    logger.error("Error verifying payment intent:", error);
    return {
      success: false,
      error: error.type || "PAYMENT_VERIFICATION_FAILED",
      message: error.message,
    };
  }
});

/**
 * Cloud Function to cancel a Payment Intent
 */
exports.cancelPaymentIntent = onCall(async (request) => {
  try {
    const {paymentIntentId, cancellationReason = "requested_by_customer"} = request.data;

    // Validate auth
    if (!request.auth) {
      logger.warn("Unauthenticated request to cancelPaymentIntent");
      throw new Error("Authentication required");
    }

    // Validate input
    if (!paymentIntentId) {
      logger.warn("Missing payment intent ID");
      throw new Error("Payment Intent ID is required");
    }

    logger.info("Canceling payment intent:", {
      paymentIntentId,
      cancellationReason,
      authUid: request.auth.uid,
    });

    // Cancel payment intent with Stripe
    const paymentIntent = await stripe.paymentIntents.cancel(paymentIntentId, {
      cancellation_reason: cancellationReason,
    });

    logger.info("Payment intent canceled successfully:", {
      paymentIntentId: paymentIntent.id,
      status: paymentIntent.status,
      canceledAt: paymentIntent.canceled_at,
    });

    return {
      success: true,
      paymentIntent: {
        id: paymentIntent.id,
        status: paymentIntent.status,
        canceled_at: paymentIntent.canceled_at,
        cancellation_reason: paymentIntent.cancellation_reason,
      },
    };
  } catch (error) {
    logger.error("Error canceling payment intent:", error);
    return {
      success: false,
      error: error.type || "PAYMENT_CANCELLATION_FAILED",
      message: error.message,
    };
  }
});

/**
 * Cloud Function to get receipt URL for a charge
 */
exports.getReceiptUrl = onCall(async (request) => {
  try {
    const {chargeId} = request.data;

    // Validate auth
    if (!request.auth) {
      logger.warn("Unauthenticated request to getReceiptUrl");
      throw new Error("Authentication required");
    }

    // Validate input
    if (!chargeId) {
      logger.warn("Missing charge ID");
      throw new Error("Charge ID is required");
    }

    logger.info("Getting receipt URL for charge:", {
      chargeId,
      authUid: request.auth.uid,
    });

    // Retrieve charge from Stripe
    const charge = await stripe.charges.retrieve(chargeId);

    if (!charge.receipt_url) {
      logger.warn("No receipt URL available for charge:", chargeId);
      throw new Error("Receipt not available for this charge");
    }

    logger.info("Receipt URL retrieved successfully:", {
      chargeId,
      receiptUrl: charge.receipt_url,
    });

    return {
      success: true,
      receiptUrl: charge.receipt_url,
      chargeId: charge.id,
      amount: charge.amount,
      currency: charge.currency,
      created: charge.created,
    };
  } catch (error) {
    logger.error("Error getting receipt URL:", error);
    return {
      success: false,
      error: error.type || "RECEIPT_RETRIEVAL_FAILED",
      message: error.message,
    };
  }
});

/**
 * Cloud Function to get receipt URL from payment intent ID
 */
exports.getReceiptFromPaymentIntent = onCall(async (request) => {
  try {
    const {paymentIntentId} = request.data;

    // Validate auth
    if (!request.auth) {
      logger.warn("Unauthenticated request to getReceiptFromPaymentIntent");
      throw new Error("Authentication required");
    }

    // Validate input
    if (!paymentIntentId) {
      logger.warn("Missing payment intent ID");
      throw new Error("Payment Intent ID is required");
    }

    logger.info("Getting receipt URL from payment intent:", {
      paymentIntentId,
      authUid: request.auth.uid,
    });

    // Retrieve payment intent from Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    if (!paymentIntent.latest_charge) {
      logger.warn("No charge ID available for payment intent:", paymentIntentId);
      throw new Error("No charge found for this payment intent");
    }

    // Retrieve charge from Stripe
    const charge = await stripe.charges.retrieve(paymentIntent.latest_charge);

    if (!charge.receipt_url) {
      logger.warn("No receipt URL available for charge:", paymentIntent.latest_charge);
      throw new Error("Receipt not available for this charge");
    }

    logger.info("Receipt URL retrieved successfully from payment intent:", {
      paymentIntentId,
      chargeId: paymentIntent.latest_charge,
      receiptUrl: charge.receipt_url,
    });

    return {
      success: true,
      receiptUrl: charge.receipt_url,
      chargeId: charge.id,
      paymentIntentId: paymentIntent.id,
      amount: charge.amount,
      currency: charge.currency,
      created: charge.created,
    };
  } catch (error) {
    logger.error("Error getting receipt URL from payment intent:", error);
    return {
      success: false,
      error: error.type || "RECEIPT_RETRIEVAL_FAILED",
      message: error.message,
    };
  }
});

/**
 * Cloud Function to refund a payment
 */
exports.refundPayment = onCall(async (request) => {
  try {
    const {paymentIntentId, reason = "requested_by_customer", amount} = request.data;

    // Validate auth
    if (!request.auth) {
      logger.warn("Unauthenticated request to refundPayment");
      throw new Error("Authentication required");
    }

    // Validate input
    if (!paymentIntentId) {
      logger.warn("Missing payment intent ID");
      throw new Error("Payment Intent ID is required");
    }

    logger.info("Processing refund for payment intent:", {
      paymentIntentId,
      reason,
      amount,
      authUid: request.auth.uid,
    });

    // Retrieve payment intent from Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    if (!paymentIntent.latest_charge) {
      logger.warn("No charge ID available for payment intent:", paymentIntentId);
      throw new Error("No charge found for this payment intent");
    }

    if (paymentIntent.status !== "succeeded") {
      logger.warn("Payment intent is not succeeded, cannot refund:", {
        paymentIntentId,
        status: paymentIntent.status,
      });
      throw new Error("Payment must be succeeded to process refund");
    }

    // Create refund
    const refundParams = {
      charge: paymentIntent.latest_charge,
      reason: reason,
    };

    // Add amount if partial refund is requested
    if (amount && amount > 0 && amount < paymentIntent.amount) {
      refundParams.amount = Math.round(amount);
    }

    const refund = await stripe.refunds.create(refundParams);

    logger.info("Refund processed successfully:", {
      paymentIntentId,
      refundId: refund.id,
      amount: refund.amount,
      status: refund.status,
    });

    return {
      success: true,
      refund: {
        id: refund.id,
        amount: refund.amount,
        currency: refund.currency,
        status: refund.status,
        reason: refund.reason,
        charge: refund.charge,
        created: refund.created,
      },
    };
  } catch (error) {
    logger.error("Error processing refund:", error);
    return {
      success: false,
      error: error.type || "REFUND_FAILED",
      message: error.message,
    };
  }
});

exports.sendNotification = functions.https.onCall(async (data) => {
  console.log("📥 FCM 알림 전송 요청");

  // Firebase Functions v2에서 실제 데이터는 data.data 안에 있음
  const requestData = data.data || data;

  const hasTokens = requestData && requestData.tokens;
  const hasTopic = requestData && requestData.topic;

  console.log(`📋 전송 방식: ${hasTopic ? "토픽" : "토큰"} 기반`);

  // 기본 검증
  if (!requestData) {
    throw new functions.https.HttpsError("invalid-argument", "유효한 데이터가 필요합니다.");
  }

  if (!hasTokens && !hasTopic) {
    throw new functions.https.HttpsError("invalid-argument", "유효한 tokens 배열 또는 topic이 필요합니다.");
  }

  if (!requestData.title || !requestData.body) {
    throw new functions.https.HttpsError("invalid-argument", "title과 body는 필수입니다.");
  }

  // 토큰 방식인 경우 배열 검증
  let tokens = null;
  if (hasTokens) {
    tokens = requestData.tokens;
    if (!Array.isArray(tokens)) {
      if (typeof tokens === "object" && tokens !== null) {
        tokens = Object.values(tokens);
      } else {
        throw new functions.https.HttpsError("invalid-argument", "유효한 tokens 배열이 필요합니다.");
      }
    }

    if (tokens.length === 0) {
      throw new functions.https.HttpsError("invalid-argument", "유효한 tokens 배열이 필요합니다.");
    }
  }

  try {
    console.log(`📧 제목: ${requestData.title}`);
    console.log(`📝 내용: ${requestData.body}`);

    if (hasTopic) {
      // 토픽 기반 알림 전송
      const result = await admin.messaging().send({
        topic: requestData.topic,
        notification: {
          title: requestData.title,
          body: requestData.body,
        },
      });

      console.log("✅ 토픽 알림 전송 완료:", result);

      return {
        type: "topic",
        topic: requestData.topic,
        messageId: result,
        success: true,
      };
    } else {
      // 토큰 기반 알림 전송
      const response = await admin.messaging().sendEachForMulticast({
        tokens: tokens,
        notification: {
          title: requestData.title,
          body: requestData.body,
        },
      });

      const successCount = response.responses.filter((r) => r.success).length;
      const failureCount = response.responses.filter((r) => !r.success).length;

      console.log(`✅ 토큰 알림 전송 완료: 성공 ${successCount}, 실패 ${failureCount}`);

      // 실패한 경우 상세 정보 로그
      if (failureCount > 0) {
        response.responses.forEach((result, index) => {
          if (!result.success) {
            console.log(`❌ 토큰 ${index} 전송 실패:`, result.error && result.error.message);
          }
        });
      }

      return {
        type: "tokens",
        successCount: successCount,
        failureCount: failureCount,
      };
    }
  } catch (error) {
    console.log("❌ FCM 전송 중 오류:", error.message);
    throw new functions.https.HttpsError("internal", `FCM 전송 실패: ${error.message}`);
  }
});
