# MarvelImageLoader

Carregador de imagens remoto para aplicações iOS, distribuído por Swift Package Manager e construído somente com APIs nativas.

## Requisitos

- iOS 13 ou superior
- Swift 5.9 ou superior
- Xcode 15 ou superior

## Recursos

- carregamento assíncrono com `URLSession`
- cache em memória com `NSCache`
- cancelamento de requisições
- proteção contra imagens incorretas em células reutilizadas
- callback entregue na thread principal
- API orientada a protocolos para facilitar testes
- nenhuma dependência externa

## Instalação

No Xcode, acesse **File > Add Package Dependencies** e informe a URL deste repositório.

## Uso

```swift
import MarvelImageLoader

imageView.setImage(
    from: character.imageURL,
    placeholder: UIImage(named: "placeholder")
)
```

Para injeção e testes, dependa do protocolo `ImageLoading`:

```swift
final class CharacterCell {
    private let imageLoader: ImageLoading

    init(imageLoader: ImageLoading) {
        self.imageLoader = imageLoader
    }
}
```

## Branches

- `master`: versões estáveis
- `develop`: integração das próximas entregas
- `feat/{nome-da-feature}`: desenvolvimento de funcionalidades

Features retornam para `develop` por Pull Request. Versões estabilizadas seguem de `develop` para `master`.

## Licença e direitos de terceiros

O código próprio é disponibilizado sob a [licença MIT](LICENSE), para estudo,
modificação e reutilização, inclusive comercial, respeitadas suas condições.
Essa permissão não abrange marcas ou materiais de terceiros.

Projeto independente, sem afiliação ou endosso da Marvel ou da Disney.
Consulte [Direitos de terceiros](THIRD_PARTY_NOTICES.md) para o escopo da licença,
os avisos e as condições que devem ser verificadas antes de distribuir conteúdo.
