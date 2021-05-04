# flutter_shortener

A Library for generating short links.
It provides methods to generate/update short links from multiple providers.
Currently only supports Bit.ly.

More Providers Coming Soon...

## Providers Supported

- Bit.ly
- More Coming Soon

## Bit.Ly Example

```dart
  try{
    final shortener = BitLyShortener(
      accessToken: "YOUR_TOKEN",
    );
    BitLyLinkData linkData=await shortener.generateShortLink(
      longUrl: 'ANY_URL',
    );
    print(linkData.link);
  }
  on BitLyException catch(e){ //For handling BitLyException
    print(e);
  }
  on Exception catch(e){ // For handling other Exceptions related to http package
    print(e);
  }
```
