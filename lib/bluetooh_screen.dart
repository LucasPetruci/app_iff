import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<ScanResult> devices =
      []; // Lista para armazenar os dispositivos encontrados
  late StreamSubscription
      scanSubscription; // Para controlar a assinatura do escaneamento

  @override
  void dispose() {
    // Certifique-se de cancelar o escaneamento ao fechar a tela
    scanSubscription.cancel();
    super.dispose();
  }

  void _checkDevice() async {
    if (await FlutterBluePlus.isSupported == false) {
      print('Bluetooth is not supported');
      return;
    }
  }

  void _setBluetoothState() async {
    _checkDevice();
    var subscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        _startScan();
      } else {
        print("Error: Bluetooth is off");
      }
    });

    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    // Cancela a assinatura quando o escaneamento termina
    subscription.cancel();
  }

  void _startScan() {
    // Inicia o escaneamento de dispositivos
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));

    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (results.isNotEmpty) {
        setState(() {
          devices = results; // Atualiza a lista de dispositivos encontrados
        });
      }
    }, onError: (e) => print('Erro durante o escaneamento: $e'));

    // Cancela a assinatura quando o escaneamento termina
    FlutterBluePlus.cancelWhenScanComplete(scanSubscription);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Device Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _setBluetoothState, // Chama o escaneamento ao clicar
          ),
        ],
      ),
      body: devices.isEmpty
          ? const Center(child: Text('Nenhum dispositivo encontrado'))
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                ScanResult result = devices[index];
                return ListTile(
                  title: Text(result.device.name.isNotEmpty
                      ? result.device.name
                      : 'Dispositivo sem nome'),
                  subtitle: Text(result.device.remoteId.toString()),
                  trailing: ElevatedButton(
                    child: const Text('Conectar'),
                    onPressed: () {
                      // Ação para conectar ao dispositivo
                    },
                  ),
                );
              },
            ),
    );
  }
}
