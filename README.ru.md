# SCCP Manager

Модуль FreePBX для телефонов Cisco по протоколу SCCP.

Он управляет SCCP-extensions, кнопками телефонов, BLF, несколькими линиями, provisioning и интеграцией со страницей устройства FreePBX.

English version: [README.md](README.md)

## Что нужно

- FreePBX 16 или 17
- PHP 8.2+
- Asterisk 21 / 22 / 23
- `chan-sccp` 4.3.5+ из рабочей сборки
- расширение PHP `zip`
- TFTP и DHCP для provisioning телефонов

Штатная сборка `chan-sccp` из дистрибутива может быть слишком старой или неполной. Используйте рабочую сборку из ссылки ниже.

## Рабочий драйвер

- Драйвер: рабочая сборка chan-sccp
- Wiki драйвера: здесь не дублируется
- Upstream: оригинальный проект chan-sccp

## Установка модуля

### Через веб-интерфейс FreePBX

1. Открой **Admin** -> **Module Admin**.
2. Нажми **Upload Modules**.
3. В поле **Download From Web** вставь:

```text
https://github.com/timspb/sccp_manager/archive/refs/heads/develop.zip
```

4. Нажми **Download From Web**.
5. Открой **Manage Local Modules**.
6. Найди **SCCP Manager**.
7. Нажми **Install**.
8. Нажми **Process**.
9. Дождись завершения установки.
10. Нажми **Apply Config** в правом верхнем углу FreePBX.

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

1. Открой **Applications** -> **SCCP Connectivity**.
2. Создай или отредактируй телефоны и линии.
3. Открой страницу extension/phone и задай SCCP-параметры.
4. После сохранения нажми **Apply Config**.
5. При необходимости перезагрузи или перепризови телефон.

## Если что-то не работает

- Если FreePBX не скачивает ZIP, проверь, что ссылка ведёт на `timspb/sccp_manager`.
- Если телефоны не provisionятся, проверь TFTP и DHCP.
- Если регистрация не проходит, проверь, что `chan-sccp` установлен, запущен и подходит к твоей версии Asterisk.
- Если SCCP-настройки не сохраняются, проверь актуальность версии модуля и значения во вкладке SCCP на странице устройства.

## Примечания

- Этот репозиторий - рабочий форк для разработки.
- Оригинальный upstream находится в истории проекта chan-sccp.
- Для этого форка используй ссылки выше, чтобы пользователи не копировали upstream-URL по ошибке.
