import 'package:test/test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:testtapp/models/User.dart';

// Mock class for DocumentReference
class MockDocumentReference extends Mock implements DocumentReference {}

void main() {
  test('UserDataBase initial values should be set correctly', () {
    final mockUserTypeId = MockDocumentReference();
    final user = UserDataBase(
      UID: '123',
      email: 'test@example.com',
      name: 'Test User',
      user_type_id: mockUserTypeId,
      phone: '1234567890',
      address: '123 Test St',
      isActive: true,
      imageUrl: 'http://example.com/image.jpg',
    );

    expect(user.UID, '123');
    expect(user.email, 'test@example.com');
    expect(user.name, 'Test User');
    expect(user.user_type_id, mockUserTypeId);
    expect(user.phone, '1234567890');
    expect(user.address, '123 Test St');
    expect(user.isActive, true);
    expect(user.imageUrl, 'http://example.com/image.jpg');
  });
}
