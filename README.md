# 2024-NC2-M18-MachineLearning
## 🎥 Youtube Link
(추후 만들어진 유튜브 링크 추가)

## 💡 About Machine Learning
**AI**는 **컨셉**이고 **머신러닝**은 일종의 **메소드**입니다.<br/>
머신러닝은 AI 기술의 한 가지 방법론으로, 데이터 학습을 통해 사람의 직접적인 개입 없이도 컴퓨터가 **패턴**을 파악하고 판단하는 작업을 수행하게 됩니다. 패턴을 활용해 새로운 데이터에 대한 예측을 수행하거나, 없던 데이터를 예측에 걸맞게 생성할 수 있게 됩니다.<br/><br/>
`CreateML`과 `CoreML`을 통해 템플릿을 활용하여 직접 손쉽게 모델을 학습시키고 도입할 수 있다는 점 외에, `Vision`과 같은 프레임워크를 통해 높은 성능으로 pre-trained된 모델을 사용하여 용도에 맞게 파이프라인을 구성하는 법을 알게 되었습니다. `CreateML`에서 **Hand Pose Classification**과 **Hand Action Classification**을 통해 손 관절`Landmark` 감지 위에 손 모양과 동작을 학습시킬 수 있고, **Action Classification**으로 신체 포즈와 동작을 학습시킬 수 있습니다. `AVFoundation`의 카메라 구현과 `Vision` 프레임워크의 Detect ∙ Recognize 관련 클래스를 통해 실시간으로 손 마디의 위치 데이터를 다룰 수 있습니다.

## 🎯 What we focus on?
- **실시간으로 손의 위치와 상태를 감지 (Detect Hand Pose)**
    
    애플이 미리 모델을 학습시켜 제공하는 `Vision` 프레임워크를 사용하여
    실시간으로 손의 관절 위치를 감지합니다.
    
- **손 동작 인식 및 분류 (Hand Action Classification)**
    
    카메라가 분류해낼 수 있도록 직접 수집한 대량의 손 동작 비디오를 `CreateML`로 학습시켜 `Hand Action Classifier` 모델을 생성하였습니다. 카메라를 통해 `Vision` 프레임워크로 실시간 파악된 손 관절의 움직임
    데이터를 `CoreML`을 통해 `Hand Action Classifier`에 입력하여 특정 동작을 인식하고 분류합니다.
    
- **백그라운드에서 재생되는 Apple Music 제어**
카메라로 감지되는 손동작에 맞추어 `AVAudioSession`과 `MPMusicPlayerController`를 통해 음악 재생을 제어합니다. 음악을 멈추거나 다음 곡을 재생시키고 볼륨을 조절합니다.

## 💼 Use Case
모바일 화면 터치나 Bluetooth 기기 없이 손 제스처만으로 Apple Music 재생관련 기능을 제어할 수 있다.

## 🖼️ Prototype
<img width="603" alt="NC2_prototypeUI" src="https://github.com/DeveloperAcademy-POSTECH/2024-NC2-M18-MachineLearning/assets/110075512/824ae824-1977-4a63-bbff-e415c6118cde">

## 🛠️ About Code
```// 비디오 프레임에서 손의 위치와 제스처를 감지하기 위한 request 객체 생성
var handPoseRequest = VNDetectHumanHandPoseRequest()

// 손 감지에 대한 이미지 처리 요청을 수행
let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
try handler.perform([handPoseRequest])
if let results = handPoseRequest.results?.first {
    processHandPoseObservation(results)
}

// CreateML로 자체 생성한 손동작 분류 모델을 도입
let model = try! HandActionClassifier(configuration: MLModelConfiguration())

// 실시간 비디오로 감지한 손 데이터를 input값으로 넣어 어떤 손동작인지 예측 및 분류
let poses = MLMultiArray(concatenating: queue, axis: 0, dataType: .float32)
let input = HandActionClassifierInput(poses: poses)
let prediction = try? model.prediction(input: input)
```

### 🔀 Github Convention
### 이슈
- 템플릿 사용
```swift
## Description
설명을 작성하세요.

## To-do
- [ ] todo
- [ ] todo

## ETC
```
1. 이슈를 등록할 때 맨 앞에 이슈 종류 쓰기 (예: `[feat] 홈 UI 구현`)
2. 이슈에 맞는 `label` 달기
3. 이슈를 등록하면 번호가 할당됨 -> 브랜치, 커밋에 사용

### 브랜치
- 브랜치명 = `분류` /`#이슈 번호` - `작업할 뷰` - `상세 작업 내역`
- 브랜치명 = `분류` /`#이슈 번호` - `작업할 내용`
```swift
chore/#3-Project-Setting
feat/#3-HomeView-UI
```

### 커밋
- 커밋 메시지 앞에 `[#이슈번호]` 넣기
  - 이렇게 하면 그 커밋에 관련된 이슈를 확인할 수 있음
```swift
[#10] 홈 UI 구현
```
