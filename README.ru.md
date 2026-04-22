# SCCP Manager

Модуль FreePBX для телефонов Cisco SCCP.

Он управляет SCCP-линиями, кнопками устройств, BLF, несколькими линиями, подготовкой телефонов и интеграцией со страницей устройства FreePBX.

[English](README.md) | Русский

## Что нужно

- FreePBX 16 или 17
- PHP 8.2+
- Asterisk 21 / 22 / 23
- `chan-sccp` 4.3.5+ из рабочей сборки
- PHP-расширение `zip`
- TFTP и DHCP для подготовки телефонов

Штатная сборка `chan-sccp` из дистрибутива может быть слишком старой или неполной. Используйте рабочую сборку по ссылке ниже.

## Рабочий драйвер

- Драйвер: рабочая сборка `chan-sccp`
- Wiki драйвера: здесь не дублируется
- Upstream: оригинальный проект `chan-sccp`

## Установка модуля

### Через веб-интерфейс FreePBX

1. Откройте **Admin** -> **Module Admin**.
2. Нажмите **Upload Modules**.
3. В поле **Download From Web** вставьте:

```text
https://github.com/timspb/sccp_manager/archive/refs/heads/develop.zip
```

4. Нажмите **Download From Web**.
5. Откройте **Manage Local Modules**.
6. Найдите **SCCP Manager**.
7. Нажмите **Install**.
8. Нажмите **Process**.
9. Дождитесь завершения установки.
10. Нажмите **Apply Config** в правом верхнем углу FreePBX.

### Через shell

```bash
cd /var/www/html/admin/modules
git clone https://github.com/timspb/sccp_manager.git
fwconsole ma install sccp_manager
fwconsole reload
```

## Обновление

```bash
fwconsole ma upgrade sccp_manager
fwconsole reload
```

## Готовый ZIP

Если удобнее загрузить готовый пакет в FreePBX:

```text
https://github.com/timspb/sccp_manager/raw/develop/dist/sccp_manager-17.0.1.1.zip
```

## После установки

1. Откройте **Applications** -> **SCCP Connectivity**.
2. Создайте или отредактируйте телефоны и линии.
3. Откройте страницу extension/phone и задайте параметры SCCP.
4. После сохранения нажмите **Apply Config**.
5. При необходимости перезагрузите телефон или отправьте ему reload.

## Если что-то не работает

- Если FreePBX не скачивает ZIP, проверьте, что ссылка ведёт на `timspb/sccp_manager`.
- Если телефоны не получают конфигурацию, проверьте TFTP и DHCP.
- Если регистрация не проходит, убедитесь, что `chan-sccp` установлен, запущен и подходит к вашей версии Asterisk.
- Если параметры SCCP не сохраняются, проверьте актуальность версии модуля и значения во вкладке SCCP на странице устройства.

## Примечания

- Это рабочий форк для разработки.
- Оригинальный upstream-проект по-прежнему доступен в истории `chan-sccp`.
- Для этого форка используйте ссылки выше, чтобы случайно не подставить upstream-URL.
