import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dto/UserDto.dart';
import '../../providers/firebase/FirebaseAuthServiceProvider.dart';
import '../../providers/firebase/FirebaseStoreServiceProvider.dart';
import '../../utils/AppStrings.dart';
import 'SignUpPage.dart';

final signUpProvider = FutureProvider((ref) async {
  // Simulate a network request with a 2-second delay
  await Future.delayed(Duration(seconds: 2));
  return true;
});

class ConfirmationPage extends ConsumerWidget {
  final VoidCallback onNext;

  ConfirmationPage({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.read(emailProvider.notifier);
    final name = ref.read(nameProvider.notifier);
    final nickname = ref.read(nicknameProvider.notifier);
    final password = ref.read(passwordProvider.notifier);
    final isLoading = ref.watch(signUpProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('이메일: ${email.state}'),
          SizedBox(height: 20),
          Text('이름: ${name.state}'),
          SizedBox(height: 20),
          Text('닉네임: ${nickname.state}'),
          SizedBox(height: 20),
          Text('비밀번호: ${password.state}'),
          SizedBox(height: 20),
          Row(
            children: [
              Checkbox(value: true, onChanged: (value) {}),
              Text('개인정보 처리방침에 동의합니다.'),
            ],
          ),
          Row(
            children: [
              Checkbox(value: true, onChanged: (value) {}),
              Text('이용약관에 동의합니다.'),
            ],
          ),
          SizedBox(height: 20),
          isLoading.when(
            data: (value) => ElevatedButton(
              onPressed:
                  signUp(email.state, password.state, name.state, context, ref),
              child: Text('가입하기'),
            ),
            loading: () => CircularProgressIndicator(),
            error: (error, stackTrace) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }

  signUp(email, password, name, context, ref) async {
    try {
      // 사용자 계정 생성
      var userCredential = await ref
          .read(firebaseAuthServiceProvider)
          .signUpWithEmailPassword(email, password);

      // 새로운 UserDTO 인스턴스 생성
      UserDTO newUser = UserDTO(
          userId: userCredential!.uid,
          email: email,
          name: name,
          // 초기 이름 값, 필요에 따라 수정
          age: 0,
          // 초기 나이 값, 필요에 따라 수정
          profileImageUrl: '',
          // 초기 프로필 사진 URL, 필요에 따라 수정
          createdAt: DateTime.now() // 계정 생성 날짜
          );

      // Firestore에 사용자 정보 저장
      await ref.read(firebaseStoreServiceProvider).createUser(newUser);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.signUpSuccessMessage)),
      );
    } catch (e) {
      // 회원가입 실패 시, 에러 메시지 출력
      print('회원가입 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('회원가입 실패: $e'),
      ));
    }
  }
}
