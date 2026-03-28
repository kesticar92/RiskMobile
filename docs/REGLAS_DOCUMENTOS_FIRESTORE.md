# Reglas Firestore para coleccion `documents` (RF35)

Agrega estos bloques a tu `firestore.rules` existente (no reemplaces todo el archivo si ya tienes reglas para `users`, `cases`, etc.):

```
match /documents/{docId} {
  allow create: if request.auth != null
    && request.resource.data.userId == request.auth.uid;
  allow read, update, delete: if request.auth != null
    && resource.data.userId == request.auth.uid;
}
```

**Indice compuesto** (si Firebase lo solicita al consultar casos):

- Coleccion: `cases`
- Campos: `clientId` Ascendente, `createdAt` Descendente

## Firebase Storage

En la raiz del repo hay `storage.rules`. Si usas Firebase CLI, configura `firebase.json` con la seccion `storage` apuntando a ese archivo y ejecuta:

`firebase deploy --only storage`
