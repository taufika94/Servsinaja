// ═══════════════════════════════════════
// METODE PEMBAYARAN
// ═══════════════════════════════════════
enum PaymentMethod {
  qris,           // QRIS (QR Code)
  bankTransfer,   // Transfer Bank
  eWallet,        // E-Wallet (GoPay, OVO, Dana)
  creditCard,     // Kartu Kredit
  cash,           // Bayar di Tempat (COD)
}

extension PaymentMethodExt on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.bankTransfer:
        return 'Transfer Bank';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
      case PaymentMethod.creditCard:
        return 'Kartu Kredit';
      case PaymentMethod.cash:
        return 'Bayar di Tempat';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.qris:
        return 'Scan QR dengan aplikasi bank/e-wallet';
      case PaymentMethod.bankTransfer:
        return 'Transfer ke rekening bengkel';
      case PaymentMethod.eWallet:
        return 'Bayar via GoPay, OVO, Dana';
      case PaymentMethod.creditCard:
        return 'Visa, Mastercard, JCB';
      case PaymentMethod.cash:
        return 'Bayar langsung ke petugas';
    }
  }

  String get iconEmoji {
    switch (this) {
      case PaymentMethod.qris:
        return '📱';
      case PaymentMethod.bankTransfer:
        return '🏦';
      case PaymentMethod.eWallet:
        return '💰';
      case PaymentMethod.creditCard:
        return '💳';
      case PaymentMethod.cash:
        return '💵';
    }
  }
}

// ═══════════════════════════════════════
// STATUS PEMBAYARAN
// ═══════════════════════════════════════
enum PaymentStatus {
  pending,     // Menunggu
  paid,        // Sudah dibayar
  failed,      // Gagal
  expired,     // Kadaluarsa
}

// ═══════════════════════════════════════
// TRANSAKSI PEMBAYARAN
// ═══════════════════════════════════════
class PaymentTransaction {
  final String id;
  final String bookingId;
  final PaymentMethod method;
  final PaymentStatus status;
  final int amount;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? referenceNumber;  // no. referensi bank
  final String? qrString;         // untuk QRIS

  PaymentTransaction({
    required this.id,
    required this.bookingId,
    required this.method,
    required this.status,
    required this.amount,
    required this.createdAt,
    this.paidAt,
    this.referenceNumber,
    this.qrString,
  });
}