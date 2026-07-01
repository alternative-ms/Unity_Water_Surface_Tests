// Created by Alexander Tkachenko aka ALT , ALTernative.MS https://www.artstation.com/alternative_ms
using UnityEngine;

public class Level5_Test0_CustomRenderTexture_ColorPinPong_Controller : MonoBehaviour
{
    [SerializeField] private CustomRenderTexture _customRenderTexture;
    [SerializeField] private int _iterationsPerFrame = 1;

    [SerializeField] private bool _needUpdateOneTime = false;
    [SerializeField] private bool _needUpdate = false;

    void Start()
    {
        _customRenderTexture.Initialize();
    }

    void Update()
    {
        if (_needUpdateOneTime)
        {
            _needUpdateOneTime = false;
            _customRenderTexture.Update(_iterationsPerFrame);
        }

        if (_needUpdate) _customRenderTexture.Update(_iterationsPerFrame);
    }
}
