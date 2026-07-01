// Created by Alexander Tkachenko aka ALT , ALTernative.MS https://www.artstation.com/alternative_ms
using System.Collections;
using UnityEngine;

public class Level5_Test1_CustomRenderTexture_ColorPinPong_Controller : MonoBehaviour
{
    [SerializeField] private CustomRenderTexture _customRenderTexture;
    [SerializeField] private int _iterationsPerFrame = 1;

    [SerializeField] private bool _needUpdateOneTime = false;
    [SerializeField] private bool _needUpdate = false;

    [SerializeField] private Camera mainCamera;
    [SerializeField] private Transform brushWhiteQuad;
    [SerializeField] private Transform brushBlackQuad;

    [SerializeField] private float brushWhiteHeightOffset = 1f;
    [SerializeField] private float stepWhiteDistance = 0.1f;
    [SerializeField] private float brushBlackHeightOffset = 2f;
    [SerializeField] private float blackDistanceLerp = 0.5f;

    private Vector3 lastWhiteHitPosition;
    private Vector3 lastBlackHitPosition;
    private bool isDrawing = false;
    private Vector3 hitPosition;

    [SerializeField] private Transform brushMaskWhiteQuad;

    void Start()
    {
        brushWhiteQuad.gameObject.SetActive(false);
        brushBlackQuad.gameObject.SetActive(false);
        brushMaskWhiteQuad.gameObject.SetActive(false);

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

        if (Input.GetMouseButtonDown(0))
        {
            if (GetClickPoint())
            {
                brushWhiteQuad.localPosition = hitPosition + new Vector3(0, brushWhiteHeightOffset, 0);
                brushBlackQuad.localPosition = hitPosition + new Vector3(0, brushBlackHeightOffset, 0);
                brushMaskWhiteQuad.localPosition = hitPosition + new Vector3(0, brushWhiteHeightOffset, 0);

                lastWhiteHitPosition = hitPosition;
                lastBlackHitPosition = hitPosition;
                StartCoroutine(CaptureOneFrame());
                isDrawing = true;
            }
        }

        if (Input.GetMouseButton(0) && isDrawing)
        {
            if (GetClickPoint())
            {
                brushWhiteQuad.localPosition = hitPosition + new Vector3(0, brushWhiteHeightOffset, 0);
                brushMaskWhiteQuad.localPosition = hitPosition + new Vector3(0, brushWhiteHeightOffset, 0);

                float distance = Vector3.Distance(hitPosition, lastWhiteHitPosition);

                if (distance >= stepWhiteDistance)
                {
                    lastWhiteHitPosition = hitPosition;
                    StartCoroutine(CaptureOneFrame());
                }
            }
        }

        if (Input.GetMouseButtonUp(0))
        {
            isDrawing = false;
            brushWhiteQuad.gameObject.SetActive(false);
            brushBlackQuad.gameObject.SetActive(false);
            brushMaskWhiteQuad.gameObject.SetActive(false);
        }
    }

    private bool GetClickPoint()
    {
        hitPosition = Vector3.zero;

        Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit))
        {
            if (hit.transform == this.transform)
            {
                hitPosition = hit.point;
                return true;
            }
        }
        return false;
    }

    private IEnumerator CaptureOneFrame()
    {
        brushWhiteQuad.gameObject.SetActive(true);
        brushBlackQuad.gameObject.SetActive(true);
        brushMaskWhiteQuad.gameObject.SetActive(true);

        yield return new WaitForEndOfFrame();

        //brushWhiteQuad.gameObject.SetActive(false);
        //brushBlackQuad.gameObject.SetActive(false);
        brushMaskWhiteQuad.gameObject.SetActive(false);

        lastBlackHitPosition = Vector3.Lerp(lastBlackHitPosition, lastWhiteHitPosition, blackDistanceLerp);

        brushBlackQuad.localPosition = lastBlackHitPosition + new Vector3(0, brushBlackHeightOffset, 0);
    }
}
