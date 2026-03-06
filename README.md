# Poke App 🎮

Aplicación Flutter desarrollada como prueba técnica. Pokédex con autenticación AWS Cognito, carrusel visual de Pokémon, modo offline y personalización de tema.

---

## 📱 Funcionalidades

- **Autenticación** con AWS Cognito (registro, login, verificación de correo)
- **Carrusel visual** de Pokémon con carga infinita (no usa ListView)
- **Pantalla de detalle** con stats animadas, habilidades y animación Hero
- **Modo offline** con caché local usando Isar — los datos persisten sin internet
- **Banner de reconexión** — cuando vuelve internet aparece botón de actualizar
- **Perfil de usuario** con información real de Cognito (no hardcodeada)
- **Tema personalizable** — modo claro/oscuro + 8 colores de acento, persistidos entre sesiones

---

## 🏗 Arquitectura

Clean Architecture con organización Feature-First:

```
lib/
├── core/
│   ├── errors/          # Failures tipados (NetworkFailure, AuthFailure, etc.)
│   ├── network/         # Dio client, connectivity service
│   ├── providers/       # Theme provider
│   ├── router/          # GoRouter con rutas nombradas
│   ├── theme/           # Light y dark theme
│   ├── utils/           # Validators
│   └── widgets/         # Widgets reutilizables (GradientBackground, GradientButton, etc.)
│
└── features/
    ├── auth/
    │   ├── data/        # CognitoAuthDatasource, UserModel, AuthRepositoryImpl
    │   ├── domain/      # UserEntity, AuthRepository, UseCases
    │   └── presentation/ # LoginPage, RegisterPage, ConfirmPage, SplashPage, AuthProvider
    │
    ├── pokemon/
    │   ├── data/        # PokemonRemoteDatasource, PokemonLocalDatasource (Isar), RepositoryImpl
    │   ├── domain/      # PokemonEntity, PokemonDetailEntity, Repository, UseCases
    │   └── presentation/ # HomePage, DetailPage, PokemonProvider, Widgets
    │
    └── settings/
        └── presentation/ # SettingsPage, ProfileHeader, SettingsTile, ColorPickerRow
```

### Capas

| Capa | Responsabilidad |
|------|----------------|
| **Domain** | Entidades, repositorios abstractos, casos de uso |
| **Data** | Modelos, datasources (remoto/local), implementación del repositorio |
| **Presentation** | Páginas, widgets, providers (StateNotifier) |

---

## 🛠 Stack tecnológico

| Categoría | Tecnología |
|-----------|-----------|
| Framework | Flutter 3.x |
| Estado | flutter_riverpod + StateNotifier |
| Navegación | go_router |
| Autenticación | AWS Amplify + Cognito |
| HTTP | Dio + pretty_dio_logger |
| Caché local | isar_community |
| Conectividad | connectivity_plus |
| Imágenes | cached_network_image |
| Animaciones | Lottie |
| Patrón funcional | dartz (Either) |
| Persistencia de preferencias | flutter_secure_storage |

---

## 🔐 Configuración de AWS Cognito

1. Crea un **User Pool** en la consola de AWS con:
   - Sign-in: Email
   - Atributos requeridos: `email`, `name`
   - MFA: desactivado
   - App client: público, sin client secret

2. Crea el archivo `amplifyconfiguration.dart` en la raíz del proyecto (está en `.gitignore`):

```dart
const amplifyconfig = '''
{
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "usernameAttributes": ["EMAIL"],
                        "signupAttributes": ["EMAIL", "NAME"],
                        "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": [
                                "REQUIRES_LOWERCASE",
                                "REQUIRES_UPPERCASE",
                                "REQUIRES_NUMBERS",
                                "REQUIRES_SYMBOLS"
                            ]
                        },
                        "mfaConfiguration": "OFF",
                        "verificationMechanisms": ["EMAIL"]
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "TU_POOL_ID",
                        "AppClientId": "TU_APP_CLIENT_ID",
                        "Region": "us-east-1"
                    }
                }
            }
        }
    }
}
''';
```

---

## 🚀 Cómo correr el proyecto

### Prerequisitos

- Flutter SDK >= 3.3.0
- Dart SDK >= 3.3.0
- Cuenta AWS con Cognito configurado

### Instalación

```bash
# 1. Clonar el repositorio
git clone <url-del-repo>
cd poke_app

# 2. Instalar dependencias
flutter pub get

# 3. Generar código de Isar
dart run build_runner build --delete-conflicting-outputs

# 4. Crear amplifyconfiguration.dart con tus credenciales de Cognito
# (ver sección anterior)

# 5. Correr la app
flutter run
```

---

## 🧪 Tests

```bash
# Correr todos los tests
flutter test

# Correr con cobertura
flutter test --coverage

# Correr un archivo específico
flutter test test/features/auth/domain/usecases/login_usecase_test.dart
```

### Cobertura de tests

| Capa | Tests |
|------|-------|
| Domain - UseCases | LoginUseCase, RegisterUseCase, GetPokemonListUseCase, GetPokemonDetailUseCase |
| Data - Repository | PokemonRepositoryImpl (caché, red, offline) |
| Presentation - Providers | AuthNotifier, PokemonListNotifier, PokemonDetailNotifier |
| Presentation - Widgets | LoginPage, PokemonTypeChip, PasswordRequirements |
| Core | Validators (email, password, name, confirmPassword) |

---

## 📦 Estrategia offline

```
┌─────────────────────────────────────────┐
│           PokemonRepository             │
│                                         │
│  1. ¿Hay caché válido? → Retorna caché  │
│  2. ¿Hay internet?    → Fetch + cachea  │
│  3. Sin internet ni caché → NetworkFailure│
└─────────────────────────────────────────┘
```

- Caché válido por **24 horas**
- Todos los Pokémon visitados se cachean localmente
- Al reconectarse aparece un botón discreto para actualizar
- El carrusel nunca se interrumpe mientras hay datos cacheados

---

## 🎨 Personalización de tema

El usuario puede:
- Cambiar entre modo **claro** y **oscuro**
- Elegir entre **8 colores de acento** (Pokémon Rojo, Azul Agua, Verde Planta, Eléctrico, Psíquico, Dragón, Fuego, Océano)
- Las preferencias se persisten con `flutter_secure_storage` y se restauran al abrir la app

---

## 📡 API

Datos obtenidos de [PokéAPI](https://pokeapi.co/) — API pública y gratuita.

| Endpoint | Uso |
|----------|-----|
| `GET /pokemon?limit=20&offset=0` | Lista paginada |
| `GET /pokemon/{id}` | Detalle completo |

Imágenes: artwork oficial desde el repositorio de sprites de PokeAPI.

---

## 📁 Archivos ignorados por git

```
# Credenciales AWS — nunca subir al repositorio
amplifyconfiguration.dart

# Flutter/Dart
.dart_tool/
build/
*.g.dart (generados por build_runner)
```