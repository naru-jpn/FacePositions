FacePositions
==
顔検出と画像の位置調整

## 概要

画像の表示領域の縦横比と表示領域の縦横比が違う場合、上下もしくは左右をクリッピングして表示しなければなりません。このプロジェクトに含まれるクラス群は、顔検出を利用してより多くの顔が表示される領域を計算します。

画像データのクリッピングなどは行わずに、表示領域の計算結果のみを利用・キャッシュするので、高速で軽量な動作が期待されます。


## 使い方

```objective-c
FDImageView *imageView = [[FDImageView alloc] initWithFrame:frame];

UIImage *image = /* 画像 */;
NSString *cacheKey = /* 計算結果をキャッシュする為の識別子 */;

[imageView setImage:image cacheKey:cacheKey animated:YES];
```

計算の終了後、自動的に画像が描画されます。

表示領域の縦横比が変わった場合には計算結果も変わりますが、内部でのキャッシュ時に表示領域の縦横比の情報も利用している為、自動的に再計算が行われます。


## 検出方法の設定

画像の検出方法の設定の為に、幾つかのオプションが用意されています。

```objective-c
typedef NS_OPTIONS(NSInteger, FDFaceDetectionOptions) {
    /// デフォルト設定。全ての顔を同じ重みで扱い、もっとも顔の多く含まれる領域を求めます。顔検出の精度は Low です。
    FDFaceDetectionOptionsNone = 0,
    /// より大きい領域を占める顔により大きい重みを付け、含まれる顔の重みの合計がもっとも大きい領域を求めます。
    FDFaceDetectionOptionsFaceOrderLarge,
    /// より小さい領域を占める顔により大きい重みを付け、含まれる顔の重みの合計がもっとも大きい領域を求めます。
    FDFaceDetectionOptionsFaceOrderSmall,
    /// 顔検出の精度を High に変更します。High にする事でより良い領域が計算されるといった事はあまり期待できません。
    FDFaceDetectionOptionsAccuracyHigh,
};
```

#### 設定の例

```objective-c
[imageView setDetectionOptions:FDFaceDetectionOptionsFaceOrderLarge | FDFaceDetectionOptionsAccuracyHigh];
```





