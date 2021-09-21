package th.go.moph.covidfree;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.util.Base64;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.iot.cbor.CborMap;
import com.google.iot.cbor.CborParseException;
import com.upokecenter.cbor.CBORObject;

import org.bouncycastle.jce.provider.BouncyCastleProvider;

import java.io.ByteArrayOutputStream;

import java.math.BigInteger;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.Security;
import java.security.interfaces.ECPublicKey;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.X509EncodedKeySpec;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.zip.DataFormatException;
import java.util.zip.Inflater;

import COSE.CoseException;
import COSE.Encrypt0Message;
import COSE.KeyKeys;
import COSE.OneKey;
import COSE.Sign1Message;
import ehn.techiop.hcert.kotlin.chain.Base45Service;
import ehn.techiop.hcert.kotlin.chain.CompressorService;
import ehn.techiop.hcert.kotlin.chain.ContextIdentifierService;
import ehn.techiop.hcert.kotlin.chain.VerificationResult;
import ehn.techiop.hcert.kotlin.chain.impl.DefaultBase45Service;
import ehn.techiop.hcert.kotlin.chain.impl.DefaultCompressorService;
import ehn.techiop.hcert.kotlin.chain.impl.DefaultContextIdentifierService;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "th.go.moph.covidfree/reader";

    private static final int BUFFER_SIZE = 1024;

    private CBORObject stripLeadingZero(BigInteger input) {
        byte[] bytes = input.toByteArray();
        byte[] stripped;

        if (bytes.length % 8 != 0 && bytes[0] == 0x00) {
            stripped = Arrays.copyOfRange(bytes, 1, bytes.length);
        } else {
            stripped = bytes;
        }
        return CBORObject.FromObject(stripped);
    }

    private CBORObject getEcCurve(ECPublicKey publicKey2) {
        CBORObject keyKeys;
        switch (publicKey2.getParams().getOrder().bitLength()) {
            case 384:
                keyKeys = KeyKeys.EC2_P384;
                break;
            case 256:
                keyKeys = KeyKeys.EC2_P256;
                break;
            default:
                throw new IllegalArgumentException("unsupported EC curveSize");
        }
        return keyKeys;
    }


    private OneKey getOneKeyForValidation() throws CoseException, NoSuchAlgorithmException, InvalidKeySpecException {

        Security.addProvider(new BouncyCastleProvider());
        Security.setProperty("crypto.policy", "unlimited");

        String publicKeyB64 = "MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxISxRrl2p2adGVgmo9pZyv8B/QtU1y1Qxe0NoTl5qtjS6UPJtYKsFR+JfY/m9MhBf7co6gcZbhPKtPoPHbQTbR/t0Qug9dhixI/8yqyk2i2CstLN/qM+l2JjHLRvuCA/6gyyN1lBFFIKddSyxkk0LX8uwxfGWSIAdvlsi6m2vNT3fbUUARKsPC00UGqAZLV55MhMcOGatzGWpKIy9e5oSNIfiWGhHYekZT8iAPHoNU0vzJvTwjmo7AUFx1sgTCWD+TKzKMTsdjK5EimYvD66UCnNtn5Ofg8aBL3/8SaNmIRXpKXxwMzB+6HLtoqVTTLQIEzYCyOfKoYF28qbF99roE/h2nT1D1xlKouwldEMQVTMBKHz2clxDc9dzKwLVMORfVKAahEeCBHvl/f01/4VQT/l/x/ydohon0WrU+KoksFDgbsMq7yePBIK+rebvV7qk1xRaMO7Vyyzz287XldG9DAtGP68WCYqGxOtM8lFDSmlbJ6HEXIbNXQHLi3Si1z7JCqu+GhPhH/HXuHeIvHaB2tkEqFWGr2z8DAoV4RZZNNFoNQVu74MinNsIAnCoty1DniAqck/a2PGAhDgB+6UoFhBIuhvVLv+PfG+QUvcud+XZwmzW/cdO/WXd55nCBGYBnOFNv62RUoEHGINAcLElNpPOzps2nNJ124ugZ0bz7sCAwEAAQ==";
        byte[] decoded = Base64.decode(publicKeyB64, Base64.DEFAULT);
        X509EncodedKeySpec spec = new X509EncodedKeySpec(decoded);
        KeyFactory kf = KeyFactory.getInstance("RSA");
        RSAPublicKey generatePublic = (RSAPublicKey) kf.generatePublic(spec);

        CBORObject map = CBORObject.NewMap();
        OneKey oneKey;
        if (generatePublic instanceof RSAPublicKey) {
            RSAPublicKey rsaPublicKey = (RSAPublicKey) generatePublic;
            map.set(KeyKeys.KeyType.AsCBOR(), KeyKeys.KeyType_RSA);
            map.set(KeyKeys.RSA_N.AsCBOR(), stripLeadingZero(rsaPublicKey.getModulus()));
            map.set(KeyKeys.RSA_E.AsCBOR(), stripLeadingZero(rsaPublicKey.getPublicExponent()));
            oneKey = new OneKey(map);
        } else {
            ECPublicKey ecPublicKey = (ECPublicKey) generatePublic;
            map.set(KeyKeys.KeyType.AsCBOR(), KeyKeys.KeyType_EC2);
            map.set(KeyKeys.EC2_Curve.AsCBOR(), getEcCurve(ecPublicKey));
            map.set(KeyKeys.EC2_X.AsCBOR(), stripLeadingZero(ecPublicKey.getW().getAffineX()));
            map.set(KeyKeys.EC2_Y.AsCBOR(), stripLeadingZero(ecPublicKey.getW().getAffineY()));
            oneKey = new OneKey(map);
        }
        return oneKey;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        runOnUiThread(() -> new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            final String method = call.method;
                            final String arguments = call.arguments();

                            switch (method) {
                                case "verifyqrcode": {
                                    String qrCode = (String) arguments;

                                    VerificationResult verificationResult = new VerificationResult();
                                    ContextIdentifierService contextIdentifierService = new DefaultContextIdentifierService();
                                    Base45Service base45Service = new DefaultBase45Service();
                                    CompressorService compressorService = new DefaultCompressorService();
                                    String plainInput = contextIdentifierService.decode(qrCode, verificationResult);
                                    byte[] compressedCose = base45Service.decode(plainInput, verificationResult);

                                    byte[] cose = compressorService.decode(compressedCose, verificationResult);
                                    try {
                                        COSE.Message message = COSE.Message.DecodeFromBytes(cose);
                                        if ((message instanceof Sign1Message)) {
                                            Sign1Message singn1Message = (Sign1Message)message;

                                            OneKey oneKey = getOneKeyForValidation();

                                            Security.addProvider(new BouncyCastleProvider());
                                            Security.setProperty("crypto.policy", "unlimited");
                                            boolean valid = singn1Message.validate(oneKey);

                                            if (valid) {
                                                byte[] bytecompressed = Base45.getDecoder().decode(qrCode.substring(4));
                                                Inflater inflater = new Inflater();

                                                inflater.setInput(bytecompressed);

                                                ByteArrayOutputStream outputStream = new ByteArrayOutputStream(bytecompressed.length);

                                                byte[] buffer = new byte[BUFFER_SIZE];
                                                while (!inflater.finished()) {
                                                    int count = inflater.inflate(buffer);
                                                    outputStream.write(buffer, 0, count);
                                                }

                                                COSE.Message a = Encrypt0Message.DecodeFromBytes(outputStream.toByteArray());
                                                CborMap cborMap = CborMap.createFromCborByteArray(a.GetContent());

                                                result.success(cborMap.toJsonString());
                                            } else {
                                                result.error("NOT_VERIFY", "Certificate not verify.", null);
                                            }
                                        } else {
                                            result.error("NOT_SIGN1_COSE_MESSAGE", "Not Sign1 cose message", null);
                                        }

                                    } catch (CoseException | NoSuchAlgorithmException | InvalidKeySpecException | DataFormatException | CborParseException e) {
                                        e.printStackTrace();
                                        result.error("EXCEPTION", e.getMessage(), null);
                                    }

                                    break;
                                }
                                case "getVersion":
                                    result.success("Version 0.0.1");
                                    break;
                                case "getReaders": {
                                    // Get smartcard reader list.
                                    break;
                                }
                                case "setReader": {
                                    // Select smartcard.
                                    break;
                                }
                                case "read": {
                                    // Read smartcard data.
                                    break;
                                }

                                case "readimage": {
                                    // read smartcard image.
                                    break;
                                }
                                default:
                                    result.notImplemented();
                                    break;
                            }

                        }
                ));

    }


