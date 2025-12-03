# KC868-A16 ESPHome Configuration

Конфигурация ESPHome для контроллера Kincony KC868-A16 v1.6.

> **Важно:** В репозитории есть скрипт `fix-git-build.ps1`, устраняющий ошибку ESP-IDF на Windows (сообщения `head-ref` / `Needed a single revision`). Запускайте его перед компиляцией, если проблема повторяется.

## Описание

Этот проект содержит конфигурацию ESPHome для платы Kincony KC868-A16, которая обеспечивает:
- 16 реле для управления нагрузками
- 16 цифровых входов для датчиков
- Поддержку датчиков температуры DS18B20
- Подключение через Ethernet (LAN8720)

## Требования

- ESPHome установлен и настроен
- Python 3.7 или выше
- Git

## Установка

1. Клонируйте репозиторий:
```bash
git clone https://github.com/Luciy90/kc868-a16
cd kc868-a16
```

2. Создайте файл `secrets.yaml` на основе `secrets.yaml.example`:
```bash
cp secrets.yaml.example secrets.yaml
```

3. Отредактируйте `secrets.yaml` и укажите ваши настройки:
   - API ключ шифрования
   - OTA пароль
   - IP адрес (если нужен статический)

4. Установите зависимости ESPHome (если еще не установлены):
```bash
pip install esphome
```

## Настройка

# Аналоговые выходы и входы

#define ANALOG_A1  36
#define ANALOG_A2  34
#define ANALOG_A3  35
#define ANALOG_A4  39

IIC SDA:4
IIC SCL:5

Relay_IIC_address 0x24
Relay_IIC_address 0x25

Input_IIC_address 0x21
Input_IIC_address 0x22

DS18B20/DHT11/DHT21/LED strip -1: 32
DS18B20/DHT11/DHT21/LED strip -2: 33
DS18B20/DHT11/DHT21/LED strip -2: 14


RF433MHz wireless receiver: 2
RF433MHz wireless sender: 15

Ethernet (LAN8720) I/O define:

#define ETH_ADDR        0
#define ETH_POWER_PIN  -1
#define ETH_MDC_PIN    23
#define ETH_MDIO_PIN  18
#define ETH_TYPE      ETH_PHY_LAN8720
#define ETH_CLK_MODE  ETH_CLOCK_GPIO17_OUT

RS485:
RXD:16
TXD:13

### Сеть

По умолчанию используется статический IP адрес `192.168.0.99`. Измените настройки в `kc868-a16-a.yaml` в секции `ethernet.manual_ip` под вашу сеть.

### I2C адреса PCF8574

Конфигурация использует следующие адреса:
- Входы 1-8: `0x22`
- Входы 9-16: `0x21`
- Реле 1-8: `0x24`
- Реле 9-16: `0x25`

Если ваша плата использует другие адреса, проверьте логи после первой прошивки (включен `i2c.scan: true`) и обновите адреса в конфигурации.

### Датчики температуры

Датчики DS18B20 подключены к GPIO14 через OneWire. На самом деле вы можете использовать любой из аналоговых входов GPIO32, GPIO33, GPIO14. Если датчики не используются, закомментируйте секцию `sensor` с `dallas_temp` или установите `disabled_by_default: true`.

## Компиляция и прошивка

> **Примечание для Windows:** Перед компиляцией запустите скрипт (если возникает ошибка ESP-IDF):
> ```powershell
> powershell -ExecutionPolicy Bypass -File .\fix-git-build.ps1
> ```

### Через ESPHome Dashboard (рекомендуется)

Подробное пошаговое руководство описано в `DASHBOARD_INSTRUCTIONS.md`. Кратко:

1. Запустите Dashboard командой `esphome dashboard . --open-ui`
2. Откройте `http://localhost:6052`
3. Добавьте устройство или выберите `kc868-a16-a`
4. Нажмите "COMPILE", затем "INSTALL" (USB для первой прошивки, OTA для последующих)

### Через командную строку

```bash/powershell
# Валидация конфигурации
esphome config kc868-a16-a.yaml

# Компиляция (артефакты появятся в .esphome/build/kc868-a16-a/)
esphome compile kc868-a16-a.yaml

# Прошивка через USB (замените COM3 на ваш порт)
esphome upload kc868-a16-a.yaml --device COM3

# Прошивка через OTA (после первой прошивки через USB)
esphome upload kc868-a16-a.yaml
```

После успешной сборки ESPHome создаёт:
- `firmware.factory.bin` — полный образ для первой прошивки;
- `firmware.ota.bin` — образ для OTA-обновлений.

## Интеграция с Home Assistant

После прошивки устройство автоматически появится в Home Assistant через ESPHome API. Убедитесь, что:
- Home Assistant и устройство находятся в одной сети
- API ключ в конфигурации совпадает (или используйте автоматическое обнаружение)

## Структура проекта

```
kc868-a16/
├── kc868-a16-a.yaml      # Основная конфигурация ESPHome
├── secrets.yaml          # Секретные данные (не коммитится)
├── secrets.yaml.example  # Пример файла с секретами
├── DASHBOARD_INSTRUCTIONS.md # Руководство по ESPHome Dashboard
├── fix-git-build.ps1     # Скрипт для фикса git-ошибки ESP-IDF
├── .gitignore            # Игнорируемые файлы
└── README.md             # Этот файл
```

## Устранение неполадок

### Устройство не появляется в сети

1. Проверьте подключение Ethernet кабеля
2. Проверьте настройки IP адреса и шлюза
3. Проверьте логи через Serial порт

### Реле или входы не работают

1. Проверьте логи - должны быть видны найденные I2C устройства
2. Убедитесь, что адреса PCF8574 совпадают с логами
3. Проверьте подключение I2C шины (SDA/SCL)

### Датчики температуры не работают

1. Убедитесь, что датчики подключены к GPIO32, GPIO33 или GPIO14
2. Проверьте питание датчиков (нужен внешний источник 3.3V)
3. Проверьте логи на наличие ошибок OneWire

## Лицензия

MIT

## Автор

Создано для проекта автоматизации на базе Kincony KC868-A16


