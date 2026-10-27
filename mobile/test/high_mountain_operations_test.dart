import 'package:flutter_test/flutter_test.dart';
import 'package:huaguruncho_360/features/home/domain/municipal_notice_model.dart';
import 'package:huaguruncho_360/features/safety/domain/expedition_model.dart';
import 'package:huaguruncho_360/features/gamification/domain/guardian_models.dart';
import 'package:huaguruncho_360/features/home/domain/community_service_model.dart';

void main() {
  group('High-Mountain Operations Unit Tests', () {
    test('MunicipalNoticeModel parses JSON correctly', () {
      final json = {
        'uuid': 'notice-uuid-123',
        'title': 'Cierre preventivo de sendero',
        'subtitle': 'Nevada intensa en el collado',
        'category': 'clima',
        'category_display': 'Clima y Alta Montaña',
        'department': 'COEL Huachón',
        'priority': 'urgente',
        'priority_display': 'Urgente',
        'full_text': 'Se restringe el paso a la morrena glaciar.',
        'recommendations': 'Permanecer en campamento base.',
        'is_active': true,
      };

      final notice = MunicipalNoticeModel.fromJson(json);
      expect(notice.uuid, 'notice-uuid-123');
      expect(notice.title, 'Cierre preventivo de sendero');
      expect(notice.category, 'clima');
      expect(notice.categoryDisplay, 'Clima y Alta Montaña');
      expect(notice.priority, 'urgente');
      expect(notice.isUrgent, isTrue);
    });

    test('ExpeditionModel parses JSON, checks status and returns correctly', () {
      final now = DateTime.now();
      final expectedReturn = now.add(const Duration(hours: 6));

      final json = {
        'uuid': 'exp-uuid-456',
        'tourist_name': 'Miguel Andinista',
        'tourist_phone': '+51999888777',
        'emergency_contact_name': 'María Guardaparque',
        'emergency_contact_phone': '+51963111222',
        'route_name': 'Ascenso al Nevado Huaguruncho',
        'group_size': 3,
        'guide_name': 'Don Carlos Huamán',
        'departure_datetime': now.toIso8601String(),
        'expected_return_datetime': expectedReturn.toIso8601String(),
        'status': 'en_curso',
        'status_display': 'En Curso',
        'health_notes': 'Aclimatado a 4,200m',
        'gear_checklist_verified': true,
      };

      final expedition = ExpeditionModel.fromJson(json);
      expect(expedition.uuid, 'exp-uuid-456');
      expect(expedition.touristName, 'Miguel Andinista');
      expect(expedition.groupSize, 3);
      expect(expedition.isOngoing, isTrue);
      expect(expedition.isReturned, isFalse);

      final outJson = expedition.toJson();
      expect(outJson['tourist_name'], 'Miguel Andinista');
      expect(outJson['group_size'], 3);
      expect(outJson['gear_checklist_verified'], isTrue);
    });

    test('TrailPassportStampModel parses coordinates and copyWith', () {
      final json = {
        'uuid': 'stamp-morrena-04',
        'name': 'Sello Morrena Glaciar Huaguruncho',
        'quechuaName': 'Huaguruncho Riti Qhawana Sello',
        'altitude_masl': 4680,
        'secret_code': 'STAMP-GLA-4680',
        'order': 4,
        'is_collected': false,
        'latitude': -10.518000,
        'longitude': -75.972000,
      };

      final stamp = TrailPassportStampModel.fromJson(json);
      expect(stamp.uuid, 'stamp-morrena-04');
      expect(stamp.altitudeMasl, 4680);
      expect(stamp.latitude, -10.518000);
      expect(stamp.longitude, -75.972000);
      expect(stamp.isCollected, isFalse);

      final collectedStamp = stamp.copyWith(isCollected: true);
      expect(collectedStamp.isCollected, isTrue);
      expect(collectedStamp.latitude, -10.518000);
    });

    test('CommunityServiceModel and ReviewModel parse rating and comments', () {
      final json = {
        'uuid': 'service-guia-01',
        'name': 'Asociación de Guías de Huachón',
        'category': 'guia',
        'category_display': 'Guías de Montaña',
        'contact_phone': '+51963111222',
        'services_description': 'Guiado a lagunas y cumbre.',
        'average_rating': 4.9,
        'reviews_count': 12,
        'reviews': [
          {
            'uuid': 'rev-01',
            'author_name': 'Marco Trekker',
            'rating': 5,
            'comment': 'Excelente guía y muy atento con el medio ambiente.',
            'created_at': '2026-08-20T10:00:00Z',
          }
        ]
      };

      final service = CommunityServiceModel.fromJson(json);
      expect(service.uuid, 'service-guia-01');
      expect(service.averageRating, 4.9);
      expect(service.reviewsCount, 12);
      expect(service.reviews.length, 1);
      expect(service.reviews.first.authorName, 'Marco Trekker');
      expect(service.reviews.first.rating, 5);
    });
  });
}
