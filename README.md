# Poke App 🎮

Aplicación Flutter desarrollada como prueba técnica. Pokédex con autenticación AWS Cognito, carrusel 3D de Pokémon, modo offline, búsqueda, filtros y personalización de tema.

---

## 📱 Funcionalidades

### Autenticación
- Registro con nombre, correo y contraseña
- Verificación de correo con código de 6 dígitos
- Login con AWS Cognito
- Recuperación de código desde el login si ya tienes uno
- Mensajes de error en español
- Cierre de sesión con confirmación

### Pokédex
- **Carrusel 3D** con efecto de perspectiva
- **Carga infinita** — carga de 10 en 10 con batches de 5 requests simultáneos
- **Búsqueda** por nombre o número de Pokémon
- **Filtro por tipo** (fuego, agua, planta, etc.)
- **Contador** de Pokémon filtrados vs total cargado
- Cards con **color dinámico** según el tipo del Pokémon

### Detalle
- Imagen con animación Hero desde el carrusel
- Altura, peso y experiencia base
- Habilidades con chips del color del tipo
- Estadísticas base con barras animadas
- **Cadena de evolución** en BottomSheet moderno

### Offline
- Caché local con Isar — todos los Pokémon visitados se guardan
- Banner naranja cuando no hay conexión
- Botón flotante de "Actualizar" cuando vuelve internet
- El carrusel nunca se interrumpe si hay datos cacheados
- Caché válido por 24 horas

### Perfil y tema
- Info del usuario real desde Cognito (nombre y correo)
- Cambio entre modo **claro** y **oscuro**
- **8 colores de acento** personalizables
- Preferencias persistidas entre sesiones con `flutter_secure_storage`

---

## 🧠 Decisiones técnicas

### ¿Por qué PokéAPI?

[PokéAPI](https://pokeapi.co/) fue elegida por varias razones técnicas concretas:

- **Gratuita y sin autenticación** — no requiere API key ni registro, lo que simplifica el setup del proyecto y elimina dependencias externas innecesarias.
- **Completa y bien documentada** — expone endpoints para lista, detalle, especies, cadenas de evolución, tipos y más, lo que permite construir una app rica sin necesidad de múltiples proveedores.
- **Estable y con alta disponibilidad** — es mantenida activamente por la comunidad y tiene un SLA confiable para proyectos de este tipo.
- **RESTful estándar** — sus respuestas siguen convenciones REST predecibles, lo que facilita el mapeo a modelos con Dart.

La única limitación es que no expone los tipos en el endpoint de lista `/pokemon`, solo en el de detalle `/pokemon/{id}`. Esto se resolvió con una estrategia de **batching con concurrencia limitada** (5 requests simultáneos por página) para obtener los tipos sin saturar la API.

---

### ¿Por qué Riverpod como gestor de estado?

Se evaluaron tres opciones principales: **BLoC**, **Provider** y **Riverpod**.

**BLoC** fue descartado porque introduce mucho boilerplate (eventos, estados, mappers) para una app de esta escala. Es una buena opción en equipos grandes con flujos muy complejos, pero agrega fricción innecesaria aquí.

**Provider** fue descartado porque tiene limitaciones conocidas en cuanto a la lectura de providers fuera del árbol de widgets y no soporta bien la inyección de dependencias sin contexto.

**Riverpod** fue elegido por:
- **Compilación segura** — los providers son variables globales tipadas, los errores se detectan en tiempo de compilación.
- **Sin dependencia del contexto** — se puede leer y escuchar providers desde cualquier parte, incluidos repositorios y casos de uso.
- **`FutureProvider` y `StreamProvider` nativos** — manejan estados asíncronos (loading, data, error) sin código adicional.
- **`StateNotifier`** — permite encapsular lógica de negocio en notifiers testables de forma aislada, sin necesidad de widgets.
- **`ProviderContainer`** — facilita los tests unitarios de providers sin necesidad de montar la UI.
- **Soporte para `family`** — permite crear providers parametrizados (ej. detalle por ID) de forma limpia.

Se usó Riverpod en su versión clásica (sin `riverpod_annotation` ni `build_runner`) para mantener el código explícito y fácil de leer.

---

### ¿Por qué Isar como persistencia local?

Se evaluaron tres opciones: **SharedPreferences**, **SQLite (via drift o sqflite)** e **Isar**.

**SharedPreferences** fue descartado porque solo soporta tipos primitivos (String, int, bool). Para cachear listas de objetos complejos como `PokemonEntity` requeriría serialización manual a JSON, lo cual es frágil y lento.

**SQLite** fue descartado porque requiere escribir y mantener queries SQL manualmente o usar un ORM como Drift que introduce su propia curva de aprendizaje y generación de código adicional.

**Isar** fue elegido por:
- **Base de datos NoSQL orientada a objetos** — los modelos se definen como clases Dart anotadas, sin SQL.
- **Altísimo rendimiento** — escrito en Rust, es significativamente más rápido que SQLite para operaciones de lectura/escritura en Flutter.
- **Soporte nativo para listas y tipos complejos** — permite guardar `List<String>` directamente sin serialización manual.
- **Transacciones ACID** — garantiza consistencia en operaciones de escritura.
- **API reactiva** — soporta streams para observar cambios en tiempo real si se necesita en el futuro.

Para la persistencia de **preferencias del usuario** (tema, color de acento) se usó `flutter_secure_storage` en lugar de Isar, porque se trata de datos simples tipo clave-valor que no justifican una base de datos completa, y `flutter_secure_storage` los guarda en el keychain del sistema operativo con cifrado nativo.

---

### ¿Por qué Clean Architecture?

La arquitectura se organizó en tres capas — **Domain**, **Data** y **Presentation** — con organización **Feature-First**:

- **Domain** no depende de ningún framework. Contiene entidades puras, repositorios abstractos y casos de uso. Esto permite testear la lógica de negocio sin mocks de Flutter.
- **Data** implementa los repositorios con la estrategia **offline-first**: primero caché, luego red. Si no hay caché ni conexión, retorna un `Failure` tipado usando `Either` de `dartz`.
- **Presentation** consume los casos de uso a través de providers de Riverpod. Los widgets son lo más "tontos" posible — solo muestran el estado.

Esta separación hace que agregar nuevas features (ej. favoritos, equipos) no requiera tocar capas existentes.

---

## 🏗 Estructura del proyecto

```
lib/
├── core/
│   ├── errors/          # Failures tipados (NetworkFailure, AuthFailure, etc.)
│   ├── network/         # Dio client, connectivity service
│   ├── providers/       # Theme provider
│   ├── router/          # GoRouter con rutas nombradas
│   ├── theme/           # Light y dark theme dinámicos
│   ├── utils/           # Validators
│   └── widgets/         # GradientBackground, GradientButton, CustomTextField
│
└── features/
    ├── auth/
    │   ├── data/         # CognitoAuthDatasource, UserModel, AuthRepositoryImpl
    │   ├── domain/       # UserEntity, AuthRepository, UseCases
    │   └── presentation/ # LoginPage, RegisterPage, ConfirmPage, SplashPage, AuthProvider
    │
    ├── pokemon/
    │   ├── data/         # RemoteDatasource (Dio+batch), LocalDatasource (Isar), RepositoryImpl
    │   ├── domain/       # PokemonEntity, PokemonDetailEntity, PokemonEvolutionEntity, UseCases
    │   └── presentation/ # HomePage, DetailPage, Providers, Widgets
    │
    └── settings/
        └── presentation/ # SettingsPage, ProfileHeader, SettingsTile, ColorPickerRow
```

### Widgets de Pokemon (presentación modular)

| Widget | Responsabilidad |
|--------|----------------|
| `PokemonCarousel` | Carrusel 3D con carga infinita |
| `PokemonCard` | Card individual con color por tipo |
| `PokemonTypeChip` | Chip de tipo con color |
| `PokemonStatBar` | Barra animada de estadística |
| `PokemonInfoChip` | Chip de info (altura, peso, exp) |
| `PokemonEmptyState` | Estado vacío con animación Snorlax |
| `PokemonErrorState` | Estado de error con reintento |
| `EvolutionBottomSheet` | Cadena de evolución en bottom sheet |
| `DetailHeader` | Header del detalle con Hero |
| `DetailAbilities` | Sección de habilidades |
| `DetailStats` | Sección de estadísticas |
| `SearchBarWidget` | Barra de búsqueda |
| `TypeFilterRow` | Fila de filtros por tipo |
| `PokemonCounter` | Contador de Pokémon |
| `OfflineBanner` | Banner de sin conexión |
| `RefreshButton` | Botón flotante de actualizar |

---

## 🛠 Stack tecnológico

| Categoría | Tecnología | Razón |
|-----------|-----------|-------|
| Framework | Flutter 3.x | Requerido por la prueba |
| Estado | flutter_riverpod + StateNotifier | Ver decisiones técnicas |
| Navegación | go_router | Solución oficial de Flutter, tipada y declarativa |
| Autenticación | AWS Amplify + Cognito | Requerido por la prueba |
| HTTP | Dio | Interceptores, timeouts y manejo de errores superior a http |
| Caché local | isar_community | Ver decisiones técnicas |
| Conectividad | connectivity_plus | Plugin oficial Flutter, multiplataforma |
| Imágenes | cached_network_image | Caché automático de imágenes en disco |
| Animaciones | Lottie | Animaciones vectoriales livianas desde JSON |
| Patrón funcional | dartz (Either) | Manejo explícito de errores sin excepciones |
| Persistencia preferencias | flutter_secure_storage | Cifrado nativo en keychain del SO |

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
```

### Cobertura de tests

| Capa | Tests |
|------|-------|
| Domain - UseCases | LoginUseCase, RegisterUseCase, GetPokemonListUseCase, GetPokemonDetailUseCase |
| Data - Repository | PokemonRepositoryImpl (caché, red, offline, forceRefresh) |
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
│  3. Sin internet ni caché → Failure     │
└─────────────────────────────────────────┘
```

- Caché válido por **24 horas**
- Todos los Pokémon cargados se cachean con sus tipos
- Al reconectarse aparece botón discreto para actualizar
- El carrusel nunca se interrumpe mientras hay datos cacheados

---

## ⚡ Optimización de red

La carga de Pokémon usa **batching con concurrencia limitada**:

```
Lista de 10 Pokémon
       ↓
Batch 1: IDs 1-5  → 5 requests en paralelo
       ↓
Batch 2: IDs 6-10 → 5 requests en paralelo
       ↓
Resultado con tipos incluidos
```

Esto evita saturar la API y mantiene un tiempo de carga razonable.

---

## 🎨 Personalización de tema

El usuario puede:
- Cambiar entre modo **claro** y **oscuro**
- Elegir entre **8 colores de acento**: Pokémon Rojo, Azul Agua, Verde Planta, Eléctrico, Psíquico, Dragón, Fuego, Océano
- Las preferencias se restauran automáticamente al abrir la app

---

## 📡 API

Datos obtenidos de [PokéAPI](https://pokeapi.co/) — API pública y gratuita.

| Endpoint | Uso |
|----------|-----|
| `GET /pokemon?limit=10&offset=0` | Lista paginada |
| `GET /pokemon/{id}` | Detalle + tipos |
| `GET /pokemon-species/{id}` | Species para evolución |
| `GET /evolution-chain/{id}` | Cadena de evolución |

---

## 📁 Archivos ignorados por git

```
# Credenciales AWS
amplifyconfiguration.dart

# Generados por build_runner
*.g.dart

# Flutter
.dart_tool/
build/
```