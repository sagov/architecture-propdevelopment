Предполагается что в компании команда разработки сервисов продаж имеет полный доступ к своим сервисам, а разработчики сервисов ЖКУ только к своим

Девопс команда одна на всех и имеет доступ ко всему кластеру

| Роль            | Права роли                  | Группы пользователей |
|-----------------|-----------------------------|----------------------|
| pod-reader-ecom | get list watch              | developer-ecom       |
| pod-writer-ecom | create update patch delete  | developer-ecom       |
| pod-reader-hcs  | get list watch              | developer-hcs        |
| pod-writer-hcs  | create update patch delete  | developer-hcs        |
| pod-reader      | get list watch              | devops               |
| pod-writer      | create update patch delete  | devops               |

### Namespaces

 - Сервисы продаж  -  pd-ecom
 - Сервисы ЖКУ - pd-hcs

p/s для примера сделано разделение на 2 namespace, а по факту их 4 + финансы, и хранилище. Предположим что у финансов и хранилища нет команд разработки это готовые решения которые установили девопсы

**Использование**

```bash
cd Task4

kubectl apply -f namespace.yaml

# Пользователи
./create_users.sh

# Роли
kubectl apply -f create_roles.yaml

# Биндинг
kubectl apply -f role_bindings.yaml
```