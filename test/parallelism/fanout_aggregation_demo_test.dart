import 'package:test/test.dart';
import 'package:dart_service_framework/dart_service_framework.dart';

part 'fanout_aggregation_demo_test.g.dart';

// 🚀 SINGLE CLASS: Pricing service
@ServiceContract(remote: true)
class PricingService extends FluxService {
  @override
  Future<void> initialize() async {
    // 🚀 FLUX: Worker class will register dispatcher automatically
    await super.initialize();
  }

  Future<double> getPrice(String sku) async {
    await Future.delayed(Duration(milliseconds: 50));
    return 99.99; // Mock price
  }
}

// 🚀 SINGLE CLASS: Inventory service
@ServiceContract(remote: true)
class InventoryService extends FluxService {
  @override
  Future<void> initialize() async {
    // 🚀 FLUX: Worker class will register dispatcher automatically
    await super.initialize();
  }

  Future<int> getStock(String sku) async {
    await Future.delayed(Duration(milliseconds: 30));
    return 42; // Mock stock
  }
}

// 🚀 SINGLE CLASS: Local aggregator
class Aggregator extends FluxService {
  @override
  List<Type> get optionalDependencies => [PricingService, InventoryService];

  Future<String> getOffer(String sku) async {
    final pricing = getService<PricingService>();
    final inventory = getService<InventoryService>();
    final results = await Future.wait([
      pricing.getPrice(sku),
      inventory.getStock(sku),
    ]);
    final price = results[0] as double;
    final stock = results[1] as int;
    return 'Offer for $sku: price=\$${price.toStringAsFixed(2)}, stock=$stock';
  }
}

// 🚀 SINGLE CLASS: Implementation moved into main classes above

Future<void> _runFanoutaggregationdemoDemo() async {
  final locator = ServiceLocator();

  locator.register<Aggregator>(() => Aggregator());

  // 🚀 SINGLE CLASS: Same class for interface and implementation!
  locator.register<PricingService>(() => PricingServiceWorker());
  locator.register<InventoryService>(() => InventoryServiceWorker());

  await locator.initializeAll();

  final agg = locator.get<Aggregator>();
  await agg.getOffer('SKU-123');

  await locator.destroyAll();
}

void main() {
  group('Fanout Aggregation Demo', () {
    test('runs fanout aggregation demo successfully', () async {
      await _runFanoutaggregationdemoDemo();
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
