import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F3F3),
      padding: const EdgeInsets.only(bottom: 217),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.network(
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/e23e5b2a0599678ad4c320fcb2ef119b8469dd3795a59d85d60cd77b7350cd64?placeholderIfAbsent=true&apiKey=dead683945384c4d9613fecc215a7ace',
                      width: 18,
                      height: 12,
                      semanticLabel: 'Network status icon',
                    ),
                    const SizedBox(width: 8),
                    Image.network(
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/c1498d3c173f0f7de234e7d067f9cf152712d3b71916b791fdd55399cee2fd21?placeholderIfAbsent=true&apiKey=dead683945384c4d9613fecc215a7ace',
                      width: 17,
                      height: 12,
                      semanticLabel: 'WiFi icon',
                    ),
                    const SizedBox(width: 8),
                    Image.network(
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/78036a73020684dabfb08c2f20cf910589730b3653af3de45a7422e85d3816ad?placeholderIfAbsent=true&apiKey=dead683945384c4d9613fecc215a7ace',
                      width: 28,
                      height: 13,
                      semanticLabel: 'Battery icon',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 143),
            child: Image.network(
              'https://cdn.builder.io/api/v1/image/assets/TEMP/3086f45f847e279905544706a8d139287a0103716cc23acbf2f6f963772292ca?placeholderIfAbsent=true&apiKey=dead683945384c4d9613fecc215a7ace',
              width: 82,
              height: 96,
              semanticLabel: 'App logo',
            ),
          ),
        ],
      ),
    );
  }
}