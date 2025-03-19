import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> alRecibirNotificacion(
      NotificationResponse notificationResponse) async {}

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: alRecibirNotificacion,
      onDidReceiveBackgroundNotificationResponse: alRecibirNotificacion,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();

      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'pokemon_favoritos_channel',
          'Pokémon Favoritos',
          description: 'Canal para notificaciones de Pokémon favoritos',
          importance: Importance.high,
        ),
      );
    }
  }

  static Future<void> mostrarNotificacionInstantanea(
      String titulo, String cuerpo) async {
    const NotificationDetails detallesPlataforma = NotificationDetails(
        android: AndroidNotificationDetails(
            "pokemon_favoritos_channel", "Pokémon Favoritos",
            channelDescription:
                'Canal para notificaciones de Pokémon favoritos',
            importance: Importance.high,
            priority: Priority.high),
        iOS: DarwinNotificationDetails());

    await flutterLocalNotificationsPlugin.show(
        0, titulo, cuerpo, detallesPlataforma);
  }

  static Future<void> mostrarNotificacionConRetraso(
      String titulo, String cuerpo, int retrasoEnSegundos) async {
    await Future.delayed(Duration(seconds: retrasoEnSegundos), () async {
      await mostrarNotificacionInstantanea(titulo, cuerpo);
    });
  }

  static Future<void> mostrarNotificacionPokemonFavorito(
      String nombrePokemon) async {
    final nombre = nombrePokemon[0].toUpperCase() + nombrePokemon.substring(1);

    await mostrarNotificacionConRetraso(
        'Pokémon Favorito', '¡$nombre ahora es tu favorito!', 3);
  }
}
