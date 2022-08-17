# RSA(二) PKCS 公钥加密标准系列


# 前言

本章着重描述 RSA PCKS(Public-Key Cryptography Standards Series 公钥加密标准系列)，RSA 又称为公钥加密技术，主要的使用场景是公钥加密、私钥解密（补充，当然，私钥加密，公钥机密也是可行的，但是这样做并不安全，因为公钥是公开的，所有拿到公钥的人都可以解密，也就失去了加密的本质；不过，可以用私钥来进行签名，后续有专门的博文对此进行描述）；

为了定义 RSA 加密的标准系列，IETF 组织总共定义了 15 个子系列标准，分别用在定义标准格式、如何封装、公钥加密封装标准、私钥加密封装标准、网络传输序列化标准等等.. 具体可以参考 wikipedia PCKS 的解释: https://en.wikipedia.org/wiki/PKCS；

下面我就几个核心的系列标准进行描述，

重要：本文为作者的原创作品，转载需注明出处；

> 转载至`https://www.shangyang.me/2017/05/24/encrypt-rsa-keyformat/`

未完待续….

# PKCS #1 RSA Cryptography Standard

摘要 wikepedia 中的一段摘要，

> See [RFC 3447](https://tools.ietf.org/html/rfc3447). Defines the mathematical properties and format of RSA public and private keys (ASN.1-encoded in clear-text), and the basic algorithms and encoding/padding schemes for performing RSA encryption, decryption, and producing and verifying signatures.

定义了公钥加密技术(RSA)相关的数学属性以及相关的公钥和密钥的格式标准（通过 ASN.1 的格式标准来定义并明文展示），以及为 RSA 进行加密、解密，生成和验证签名等操作定义了基本的算法和编码/补零(padding)的方案；

可以看到，PCKS #1 主要定义了公钥加密技术 RSA 是如何通过计算机来来定义其编码、通讯格式包括公钥私钥的文本格式(通过 ASN.1 来定义)等一系列能够使用计算机来进行通讯和计算的方案；

要注意的是，PCKS #1 定义的都是明文的格式；下面我们来看看 ASN.1 是如何定义私钥和公钥的格式的，来加深我们的认知；

## ASN.1

ASN.1: https://en.wikipedia.org/wiki/Abstract_Syntax_Notation_One

> Abstract Syntax Notation One (ASN.1) is an interface description language for defining data structures that can be serialized and deserialized in a standard, cross-platform way. It’s broadly used in telecommunications and computer networking, and especially in cryptography.

ASN.1 是一种接口描述性语言，该语言定义了能够进行跨平台、序列化和反序列化的数据格式；它被广泛的用于电子通讯以及计算机网络中，特别是用在`密码学的领域`；由此可知，ASN.1 定义了一种专用于密码学领域的一种可以进行序列化和反序列化的数据格式；

> ASN.1 is used in X.509, which defines the format of certificates used in the HTTPS protocol for securely browsing the web, and in many other cryptographic systems.

ASN.1 用在 X.509 中，用来定义其证书的格式，该证书用在 HTTPS 安全通讯领域；

那么 RSA 是如何通过 ASN.1 来定义公钥和私钥的数据格式的；看下面的章节，主要参考，https://tools.ietf.org/html/rfc3447#appendix-A

### RSA public key syntax 公钥语法

https://tools.ietf.org/html/rfc3447#appendix-A.1.1

> An RSA public key should be represented with the ASN.1 type
> RSAPublicKey:

```
RSAPublicKey ::= SEQUENCE {
    modulus           INTEGER,  -- n
    publicExponent    INTEGER   -- e
}
```

> The fields of type RSAPublicKey have the following meanings:
>
> ```
> * modulus is the RSA modulus n.
> * publicExponent is the RSA public exponent e.
> ```

上面通过 ASN.1 定义了公钥的格式，通过一个 ASN.1 的 SEQUENCE 元素分别定义了 modules 和 publicExponent，而 modules 正是代表的 [模 N](https://www.shangyang.me/2017/05/19/encrypt-rsa-math/#模-N)，而 publicExponent 正式代表的[随机数 e](https://www.shangyang.me/2017/05/19/encrypt-rsa-math/#随机数-e)，而 {𝑁,𝑒}{N,e} 正好表示了公钥；

可见，通过 ASN.1 的 *SEQUENCE* 元素`RSAPublicKey`定义了公钥的数据格式，该格式便可以在网络通讯中进行序列化和反序列化；

### RSA private key syntax 私钥语法

https://tools.ietf.org/html/rfc3447#appendix-A.1.2

```
RSAPrivateKey ::= SEQUENCE {
          version           Version,
          modulus           INTEGER,  -- n
          publicExponent    INTEGER,  -- e
          privateExponent   INTEGER,  -- d
          prime1            INTEGER,  -- p
          prime2            INTEGER,  -- q
          exponent1         INTEGER,  -- d mod (p-1)
          exponent2         INTEGER,  -- d mod (q-1)
          coefficient       INTEGER,  -- (inverse of q) mod p
          otherPrimeInfos   OtherPrimeInfos OPTIONAL
}
```

可见，ASN.1 同样通过一个 *SEQUENCE* 元素`RSAPrivateKey`定义了私钥的数据格式，d 既是模反元素，p、q 两质数，exponent1 和 exponent2 分别表示 d 与 (p-1) 和 (p-2) 的余数；

可以看到 ASN.1 定义了 private key 的数据格式；

## 补充

要查看明文的 public key / private key 的 ASN.1 的源数据格式，可以通过工具 http://phpseclib.sourceforge.net/x509/asn1parse.php 查看；

# PKCS #7 Cryptographic Message Syntax Standard

Cryptographic Message Syntax Standard 被加密消息的格式标准，与 PKCS #1 不同，PKCS #7 描述的是如何对公钥和私钥 ASN.1 的文本进行加密的标准；PKCS #1 标准描述的是 RSA 加密技术相关标准的定义；先来看 Wikipedia 上的一段摘要，

> See [RFC 2315](https://tools.ietf.org/html/rfc2315). Used to sign and/or encrypt messages under a [PKI](https://en.wikipedia.org/wiki/Public_key_infrastructure). Used also for certificate dissemination (for instance as a response to a PKCS #10 message). Formed the basis for S/MIME, which is as of 2010 based on RFC 5652, an updated [Cryptographic Message Syntax Standard (CMS)](https://en.wikipedia.org/wiki/Cryptographic_Message_Syntax). Often used for single sign-on.

PKCS #7 通常在一个 PKI 中用来签名或者加密信息，也通常用于证书的传递；PKCS #7 的更新版本参考[Cryptographic Message Syntax Standard (CMS)](https://en.wikipedia.org/wiki/Cryptographic_Message_Syntax)；

从上述的描述中可以知道，PKCS #7 主要定义了消息的加密语法标准；

摘要[CMS](https://tools.ietf.org/html/rfc5652#section-3)介绍中的相关重要部分,

> The CMS describes an encapsulation syntax for data protection.
>
> The CMS can support a variety of architectures for certificate-based
> key management, such as the one defined by the PKIX (Public Key
> Infrastructure using X.509) working group [PROFILE].

CMS 用来描述数据加密的一种封装语法；

CMS 可以用于支持多种多样的证书管理实现，比如 PKIX (X.509 中的公钥管理的内部实现)；

Ok，从上述的描述中可以看到，PKCS #7 主要用在 PKI/PKIX 领域中，主要是用来进行公钥加密保存、传输等；

## PKCS #7 Format

https://crypto.stackexchange.com/questions/37084/is-pkcs7-a-signature-format-or-a-certificate-format 这篇文章对 PKCS #7 进行了比较详细的讨论；摘要部分如下，

> The *.p7b* or *.p7c* format is a special case of PKCS#7/CMS: a SignedData structure containing no “content” and zero SignerInfos, but one or more certificates (usually) and/or CRLs (rarely).

可以知道，如果使用 PKCS#7 原生格式，将会使用 *.p7c* 后缀名，如果使用的是 CMS，那么使用的是 *.p7b* 后缀；

从 https://tools.ietf.org/html/rfc5652#section-12.1 可以看到详细的 ASN.1 中有关 CMS 的标准定义，

摘要部分信息如下，

1. 数据内容信息

   ```
   ContentInfo ::= SEQUENCE {
     contentType ContentType,
     content [0] EXPLICIT ANY DEFINED BY contentType }
   
   ContentType ::= OBJECT IDENTIFIER
   ```

2. 数据签名信息

   ```
   SignedData ::= SEQUENCE {
     version CMSVersion,
     digestAlgorithms DigestAlgorithmIdentifiers,
     encapContentInfo EncapsulatedContentInfo,
     certificates [0] IMPLICIT CertificateSet OPTIONAL,
     crls [1] IMPLICIT RevocationInfoChoices OPTIONAL,
     signerInfos SignerInfos }
   ```

3. 签名者信息

   ```
   SignerInfo ::= SEQUENCE {
     version CMSVersion,
     sid SignerIdentifier,
     digestAlgorithm DigestAlgorithmIdentifier,
     signedAttrs [0] IMPLICIT SignedAttributes OPTIONAL,
     signatureAlgorithm SignatureAlgorithmIdentifier,
     signature SignatureValue,
     unsignedAttrs [1] IMPLICIT UnsignedAttributes OPTIONAL }
   ```

4. 密钥加密算法信息

   ```
   KeyTransRecipientInfo ::= SEQUENCE {
     version CMSVersion,  -- always set to 0 or 2
     rid RecipientIdentifier,
     keyEncryptionAlgorithm KeyEncryptionAlgorithmIdentifier,
     encryptedKey EncryptedKey }
   ```

5. 被加密数据的信息

   ```
   EncryptedData ::= SEQUENCE {
     version CMSVersion,
     encryptedContentInfo EncryptedContentInfo,
     unprotectedAttrs [1] IMPLICIT UnprotectedAttributes OPTIONAL }
   ```

可见，PKCS#7 定义完整的一整套的用于加密数据，签名，签名者，加密算法等等一系列信息；由此，奠定了其作为 PKI 的基础；

## PKCS #7 的用途

http://stackoverflow.com/questions/3344527/what-for-are-the-commonly-used-pkcs-standards-pkcs7-pkcs10-and-pkcs12

摘抄部分如下，

> PKCS#7 lets you sign and encrypt generic data using X.509 certificates. Also PKCS#7 format can be used to store one or more certificates without private keys (private keys can be put as a data payload and encrypted this way).

PKCS#7 使得你可以通过使用 X.509 证书对普通的数据进行签名和加密；PKCS#7 也可以用来存放不包含私钥的一个或者多个证书；

## PKI

前文提到了，PKCS#7 用来保证 PKI 的加密格式标准，保证公钥证书的安全性；

Public key infrastructure：https://en.wikipedia.org/wiki/Public_key_infrastructure

公钥基础设施，基础设施包含 CA(certificate authority)、RA、VA 等，从 wikipedia 的描述上来看，主要是为了保证公钥证书颁发途径中的安全性、保密性.. 等等相关措施，目的就是为了在公钥证书传递过程中，避免公钥被串改以后信息的不安全性..

TODO，将来准备单独写一章关于 PKI 的博文来详细的描述此类相关内容。

# PKCS #8 Private-Key Information Syntax Standard

Private-Key Information Syntax Standard 私钥信息格式标准，看 Wikipedia 的描述，

> See [RFC 5958](https://tools.ietf.org/html/rfc5958). Used to carry private certificate keypairs (encrypted or unencrypted).

用来携带`加密`的或者`未加密`的私钥证书；也就是说，PKCS#8 定义了私钥的加密和未加密的格式；

备注，最开始 PKCS#8 标准是由 RFC5208 标准定义，但是后来为了更好的支持 PKI 基础设施，由新的标准 RFC 5958 替换了原来的 RFC5208 标准，这部分内容可以从后续部分 [RFC5958 Asymmetric Key Packages](https://www.shangyang.me/2017/05/21/encrypt-rsa-pkcs/#RFC5958-Asymmetric-Key-Packages)中了解；但因为 RFC5208 更简明，所以，这里首先介绍 RFC5208 的标准内容；

## RFC5208 Private-Key Information Syntax Specification

该文档中主要包含了两个部分，private key 的原始格式 [private key info](https://www.shangyang.me/2017/05/21/encrypt-rsa-pkcs/#private-key-info) 和 private key 的加密格式 [encrypted private key info](https://www.shangyang.me/2017/05/21/encrypt-rsa-pkcs/#encrypted-private-key-info)；

https://tools.ietf.org/html/rfc5208

### private key info

Private-key information shall have ASN.1 type PrivateKeyInfo:

```
PrivateKeyInfo ::= SEQUENCE {
  version                   Version,
  privateKeyAlgorithm       PrivateKeyAlgorithmIdentifier,
  privateKey                PrivateKey,
  attributes           [0]  IMPLICIT Attributes OPTIONAL }

Version ::= INTEGER

PrivateKeyAlgorithmIdentifier ::= AlgorithmIdentifier

PrivateKey ::= OCTET STRING

Attributes ::= SET OF Attribute
```

可以看到，通过 ASN.1 格式封装了私钥，重要的有两个字段，privateKeyAlgorithm 和 privateKey；

* privateKeyAlgorithm
  表示采用的是什么算法，可以是 RSA，也可以是其它的算法，比如 DES、AES 等对称加密算法等。

* privateKey
  通过其类型可以知道，是一个

  ```
  PrivateKey ::= OCTET STRING
  ```

  可见，其由一个八位字节字符串组成；这就是私钥的内容，如果采用的是 RSA，那么自然存储的就是 {N,d} 等相关的私钥信息，详情参考[RSA private key syntax](https://www.shangyang.me/2017/05/21/encrypt-rsa-pkcs/#RSA-private-key-syntax-私钥语法)，如果采用的是 DES 算法呢，那么存储的就是 DES key 相关的信息…

摘抄两端核心的内容如下

> **privateKeyAlgorithm** identifies the private-key algorithm. One example of a private-key algorithm is PKCS #1’s rsaEncryption [PKCS#1].

privateKeyAlgorithm 表示私钥所使用的算法，一个例子就是 PKCS#1 所表述的 PKCS#1 的 rsa 加密技术；

> **privateKey** is an octet string whose contents are the value of the private key. The interpretation of the contents is defined in the registration of the private-key algorithm. For an RSA private key, for example, the contents are a BER encoding of a value of type RSAPrivateKey.

privateKey 是一个包含私钥内容的八位字节字符串 octet string，该内容由其加密算法所描述和解释；比如 RSA 私钥，其内容表示一个通过 BER 编码的私钥；

总结一下，

可以看到，PKCS #8 在原来私钥的格式上做了一层抽象封装，这样使得它可以兼容任何的私钥格式；使得 PKCS 的私钥标准可以使用到任何加密算法，这个同 PKCS#1 中定义的 RSA [私钥语法](https://www.shangyang.me/2017/05/21/encrypt-rsa-pkcs/#RSA-private-key-syntax-私钥语法)是不同的，PKCS #1 定义的只是特定的 RSA 私钥的语法格式；

Ok，从这里就可以清晰的看到 PKCS 的发展方向了，PKCS 体系已经突破了单纯的 RSA 加密算法，而是扩展到了可以适配任何的加密算法，所以，PKCS 已经成为了一种通用的密码学格式标准。当然，CMS 在此基础上更进一步，建立了 PKI 体系中所需的其它类型信息，包括加密数据，签名，签名者，加密算法等等公钥加密技术基础设施相关的东西，详情参考[PKCS #7 Format](https://www.shangyang.me/2017/05/21/encrypt-rsa-pkcs/#PKCS-7-Format)部分，而这部分正是 RFC5958 标准淘汰当前 RFC5208 标准的地方，不过精华其实还是在 RFC5208；

### encrypted private key info

https://tools.ietf.org/html/rfc5208#section-6

```
EncryptedPrivateKeyInfo ::= SEQUENCE {
  encryptionAlgorithm  EncryptionAlgorithmIdentifier,
  encryptedData        EncryptedData }

EncryptionAlgorithmIdentifier ::= AlgorithmIdentifier
```

相关核心内容摘抄如下，

> The fields of type EncryptedPrivateKeyInfo have the following meanings:

**encryptionAlgorithm** identifies the algorithm under which the private-key information is encrypted. Two examples are *PKCS #5’s pbeWithMD2AndDES-CBC* and *pbeWithMD5AndDES-CBC [PKCS#5]*.

**encryptionAlgorithm** 字段表示私钥使用什么算法进行加密的；通常使用 PKCS#5 的 *MD2AndDES* 或者 *MD5AndDES* 两种加密算法；

> **encryptedData** is the result of encrypting the private-key information.

**encryptedData** 是私钥通过加密算法 **encryptionAlgorithm** 加密以后的内容；

> The encryption process involves the following two steps:
>
> 1. The private-key information is BER encoded, yielding an octet string.
> 2. The result of step 1 is encrypted with the secret key to give an octet string, the result of the encryption process.

加密过程包含两个步骤，

1. 私钥的内容通过 BER 编码，并产生相关的八位字节字符串 octet string
2. 第一步产生的结果将会通过密钥(secret key)进行加密并再产生一个 octet string，该 octet string 便是这个加密过程的结果；

可以看到，私钥的整个内容都被 *encryptionAlgorithm* 所指明的加密算法进行了加密；

## RFC5958 Asymmetric Key Packages

看看 RFC5958 的 Introduction 章节，

> This document defines the syntax for private-key information and a
> Cryptographic Message Syntax (CMS) [RFC5652] content type for it. Private-key information includes a private key for a specified public-key algorithm and a set of attributes. The CMS can be used to digitally sign, digest, authenticate, or encrypt the asymmetric key format content type. This document obsoletes PKCS #8 v1.2 [RFC5208].

可见 RFC5958 定义了不但私钥的语法还定义了相关的 CMS 的文本类型(content type)；Private-key information 包含了一个特定公钥算法的私钥以及一些列的属性；CMS 可以用来进行数字签名，digest，验证或者用来加密非对称密钥的内容和格式；该文档淘汰了过时的 PKCS #8 v1.2 [RFC5208]；

RFC5958 Asymmetric Key Packages: https://tools.ietf.org/html/rfc5958 淘汰了过时的 RFC5208 PKCS #8: Private-Key Information Syntax Specification Version 1.2 https://tools.ietf.org/html/rfc5208；

虽然是淘汰了 RFC5208，不过笔者在阅览完 RFC5208 以后，发现 RFC5208 内容更为清晰易懂，所以，还是打算从 RFC5208 入手进行梳理；这部分内容参考 [RFC5208 Private-Key Information Syntax Specification](https://www.shangyang.me/2017/05/21/encrypt-rsa-pkcs/#RFC5208-Private-Key-Information-Syntax-Specification)

后续 RFC5958 非常详细的描述了有关 CMS 的内容定义，以及私钥加密 ASN.1 格式的定义，这里就不再一一赘述了；

### 私钥文件的格式

RFC5958 用不多的篇幅来描述了私钥的文件存储格式；不过以下内容比较零散，主要是翻译官方文档并做一些个人的理解；

该小节主要来讲解私钥的存储格式，看下 RFC5958 中的一段[描述](https://tools.ietf.org/html/rfc5958#section-5)，

> To extract the private-key information from the AsymmetricKeyPackage, the encapsulating layers need to be removed. At a minimum, the outer ContentInfo [RFC5652] layer needs to be removed. If the AsymmetricKeyPackage is encapsulated in a SignedData [RFC5652], then the SignedData and EncapsulatedContentInfo layers [RFC5652] also need to be removed. The same is true for EnvelopedData, EncryptedData, and AuthenticatedData all from [RFC5652] as well as AuthEnvelopedData from [RFC5083].

这段话的意思就是说，要提取通过 AsymmetricKeyPackage 格式所封装的私钥，必须剥离其外部的封装层；至少，外部的 ContentInfo[RFC5652] 是需要被剥离出去的；如果封装了签名，同样该签名需要被剥离；同样的，如果有其它的封装数据，比如加密的数据，验证的数据等同样需要剥离出去；

> Once all the outer layers are removed, there are as many sets of private-key information as there are OneAsymmetricKey structures. OneAsymmetricKey and PrivateKeyInfo are the same structure; therefore, either can be saved as a `.p8` file or copied in to the `P12` KeyBag BAG-TYPE. Removing encapsulating security layers will invalidate any signature and may expose the key to unauthorized disclosure.

当所有的外部层次都被剥离以后，所剩下的也就是最终私钥的信息结构了；该私钥的信息可以通过`.p8`格式文件或者是通过`P12` KeyBag BAG-TYPE 格式进行存储；不过注意的是，通过之前的步骤层层剥离，若将安全层也剥离以后，将会使得任何签名无效并且会将私钥暴露给非授权机构；

下面这段有意思了，基本上阐述了通过`.p8`格式存储的私钥的格式，不过就是不够细致，也不够生动形象，官网的内容就是这样，点到为止，看得人痛不欲生；

> `.p8` files are sometimes `PEM`-encoded. When .p8 files are `PEM` encoded they use the `.pem` file extension. `PEM` encoding is
>
> * either the `Base64` encoding, from Section 4 of [RFC4648], of the `DER`-encoded `EncryptedPrivateKeyInfo` sandwiched between:

```
-----BEGIN ENCRYPTED PRIVATE KEY-----
-----END ENCRYPTED PRIVATE KEY-----
```

> * or the Base64 encoding, see Section 4 of [RFC4648], of the
>
>    
>
>   ```
>   DER
>   ```
>
>   -encoded
>
>    
>
>   ```
>   PrivateKeyInfo
>   ```
>
>    
>
>   sandwiched between:
>
>   ```
>   -----BEGIN PRIVATE KEY-----
>   -----END PRIVATE KEY-----
>   ```

上面这段比较重要了，阐述了密钥通过`.p8`加密存储的格式，`.p8`文件是一种通过`PEM`编码的文件，当`.p8`文件通过`PEM`进行编码的时候，它们的文件后缀为`.pem`；`PEM`编码格式有两种方式

1. 使用`DER`编码的`EncryptedPrivateKeyInfo`通过`Base64`转码后被包裹下面的两段标识符中

   ```
   -----BEGIN ENCRYPTED PRIVATE KEY-----
   -----END ENCRYPTED PRIVATE KEY-----
   ```

   看过官网解释，你此时的状态应该是云里雾里的；这里作者想表达的是什么意思呢… 这里就是表示的如果私钥本身是经过加密存储的，既是 RFC5208 中所定义的 [EncryptedPrivateKeyInfo](https://www.shangyang.me/2017/05/21/encrypt-rsa-pkcs/#encrypted-private-key-info) 所表述的信息，那么会使用如上的格式来进行存储；

2. 使用`DER`编码的`PrivateKeyInfo`通过`Base64`转码后被包裹下面的两段标识符中

   ```
   -----BEGIN PRIVATE KEY-----
   -----END PRIVATE KEY-----
   ```

   `PrivateKeyInfo`这里表示的就是明文，既是密钥没有经过加密，是通过`Base64`所存储的明文格式；

更多有关此部分的介绍查看 [RSA(三) 密钥的格式](https://www.shangyang.me/2017/05/24/encrypt-rsa-keyformat/)部分内容；

---

> 作者: RoninZc  
> URL: https://ronin-zc.com/rsa%E4%BA%8C-pkcs-%E5%85%AC%E9%92%A5%E5%8A%A0%E5%AF%86%E6%A0%87%E5%87%86%E7%B3%BB%E5%88%97/  

