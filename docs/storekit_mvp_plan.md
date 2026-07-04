# StoreKit 2 и платежная схема MVP

Статус: рабочий план. В приложении сейчас реализована локальная проверка сценариев покупки, восстановления, истечения подписки и ошибки оплаты, экран подписки запрашивает каталог StoreKit 2 через `Product.products(for:)` и показывает entitlement-readiness preview. Настоящие транзакции, App Store Connect products и серверная entitlement-проверка еще не подключены.

## Продукты App Store Connect

| Product ID | Тип | Назначение | Цена MVP |
| --- | --- | --- | --- |
| `school.class.family.trial` | trial state | Локальное состояние пробного периода | 0 руб. |
| `school.class.family.monthly.child1` | auto-renewable subscription | Первый ребенок, все ключевые функции | 149 руб./мес |
| `school.class.family.monthly.extra_child` | auto-renewable subscription | Дополнительный ребенок в семье | +59 руб./мес |

Финальные цены, длительность trial и семейная модель требуют проверки в App Store Connect и коммерческого решения.

## Что должен делать StoreKit 2 слой

- [x] Загружать продукты через `Product.products(for:)`.
- [~] Показывать локализованную цену из StoreKit, а не из hardcoded строки.
- Запускать покупку через `product.purchase()`.
- Проверять `VerificationResult`.
- Сохранять только entitlement/status, а не платежные данные.
- Восстанавливать покупки через `AppStore.sync()`.
- [~] Проверять активные права через `Transaction.currentEntitlements`.
- [~] Показывать entitlement/status и будущий backend endpoint `GET /subscriptions/entitlement`.
- Обрабатывать состояния: trial, active, expired, billing retry, revoked, purchase cancelled, purchase pending, purchase failed.

## Состояния UI

Экран подписки должен показывать:

- текущий тариф;
- StoreKit product id;
- статус транзакции;
- срок действия;
- восстановление покупок;
- истекшую подписку без потери локальных данных;
- ошибку оплаты с понятным текстом;
- ограничения AI/расширенных функций без подписки.
- entitlement state: trial, active, expired, failed;
- источник проверки: local trial, StoreKit verified transaction, backend entitlement.

## Entitlement contract

Клиент не должен открывать premium-функции только по нажатию кнопки "Купить". Правильная цепочка:

1. StoreKit возвращает verified transaction.
2. Клиент обновляет локальный entitlement/status, но не хранит платежные данные.
3. Backend сверяет transaction и семейный доступ.
4. `GET /subscriptions/entitlement` возвращает `status`, `aiAccessEnabled`, `expiresAt`, `source` и `checkedAt`.
5. Если entitlement `expired`, `revoked` или `billing_retry`, AI/расширенные функции закрываются, но базовые данные семьи остаются доступны.

## Сборы класса

Сборы родкомитета в MVP остаются учетными отметками и отчетами. Они не являются in-app purchase.

Причины:

- деньги за экскурсии, подарки и материалы не являются цифровой подпиской приложения;
- нужны юридическая схема, получатель средств, чеки и правила возвратов;
- для реальных переводов может потребоваться отдельная платежная интеграция вне App Store;
- родитель должен видеть отчеты и чеки, но приложение не должно притворяться платежной системой.

## Следующие шаги

- Создать products в App Store Connect.
- Добавить StoreKit Configuration для локального Xcode-теста.
- Вынести подписку в отдельный сервис `SubscriptionStore`.
- Подключить `product.purchase()` и обработать `Product.PurchaseResult`.
- Написать unit/UI-тесты на active/expired/restore/failure.
- Подключить App Store Server Notifications для production.
