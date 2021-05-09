# flutter_shortener

A Library for generating short links.
It provides methods to generate/update short links from multiple providers.
Currently only supports Bit.ly and shorte.st.

More Providers Coming Soon...

## Providers Supported

- Bit.ly
- shorte.st
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
 } on BitLyException catch(e){ //For handling BitLyException
  print(e);
 } on Exception catch(e){ // For handling other Exceptions related to http package
  print(e);
 }
```

## shorte.st Example

```dart
 try{
   final shortener = ShorteStShortener(accessToken:"YOUR_TOKEN");
   final linkData = await shortener.generateShortLink("www.abc.xyz");
   print(linkData.shortenedUrl);
 } on Exception catch(e){//For Bad Requests
   print(e);
 }
```