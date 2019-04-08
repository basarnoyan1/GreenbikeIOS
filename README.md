# GreenbikeIOS
Bike tracking app for iOS platform.

## Sürüş sırasında

### Kilometre hesabı:
> **Formülü:** Tur sayısı * 0.66 * π / 1000

>**Birimi:** km
### Hız hesabı: 
> Hız hesabı yapılan son süre 0 olmamalıdır. 

> **Formülü:** 3600 * 0.66 * π / (Milisaniye süre - (Hız hesabı yapılan son süre))

>**Birimi:** km/h

>**Formatı** %.1f

### Ağaç hesabı: 
> **Formülü:** Milisaniye süre * 6.25 / 100000000

> **Birimi:** ağaç

> **Formatı:** %.2f

### CO2 hesabı:
> **Formülü:** Milisaniye süre * 0.125 * 1000

> **Birimi:** g CO2

> **Formatı:** %.2f

### Kalori hesabı
#### Bmr değeri:	
> **Erkek ise:** (Ağırlık * 10) + (Boy[cm] * 6.25) - (Yaş * 5) + 5

> **Kadın ise:** (Ağırlık * 10) + (Boy[cm] * 6.25) - (Yaş * 5) - 161

### Hıza bağlı Mets değeri:
#### eğer Hız < 0:
* 1
#### değilse eğer Hız < 5:
* 3.8 - (5 - Hız) * 2 / 9
#### değilse eğer Hız < 10:
* 4.8 - (10 - Hız) * 2 / 10
#### değilse eğer Hız < 15:
* 5.9 - (15 - Hız) * 2 / 11
#### değilse eğer Hız < 20:
* 7.1 - (20 - Hız) * 2 / 12
#### değilse eğer Hız < 25:
* 8.4 - (25 - Hız) * 2 / 13
#### değilse eğer Hız < 30:
* 9.8 - (30 - Hız) * 2 / 14
#### değilse eğer Hız < 35:
* 11.3 - (35 - Hız) * 2 / 15
#### değilse eğer Hız < 40:
* 12.9 - (40 - Hız) * 2 / 16
#### değilse eğer Hız < 45:
* 14.6 - (45 - Hız) * 2 / 17
#### değilse eğer Hız < 50:
* 16.4 - (50 - Hız) * 2 / 18
#### değilse:
* 18.3

### Kalori değeri:
> **Formülü:** Milisaniye süre / 360 * Bmr değeri * Mets değeri / 240

> **Birimi:** cal

## Kayıttan sonra
### Su ısıtıcı kullanma sayısı:
> **Formülü:** Milisaniye süre / 21600000

> **Birimi:** kez

> **Formatı:** %.2f
### Ampul kullanma süresi:
> **Formülü:** Milisaniye süre * 60 / 16

> **Birimi:** saat, dakika, saniye

> **Formatı:** HH:mm:ss
### Klima kullanma süresi: 
> **Formülü:** Milisaniye süre * 10 / 35

> **Birimi:** saat, dakika, saniye

> **Formatı:** HH:mm:ss
### Basınçlı hava üretme süresi:
> **Formülü:** Milisaniye süre / 540000

> **Birimi:** saniye

> **Formatı:** %.1f


