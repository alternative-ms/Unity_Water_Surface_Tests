// Created by Alexander Tkachenko aka ALT , ALTernative.MS https://www.artstation.com/alternative_ms
using UnityEngine;

public class SimpleCameraOrbit : MonoBehaviour
{
    [SerializeField] private Transform orbitTarget;
    [SerializeField] private float lerpSpeed = 3f;
    [SerializeField] private float scrollSpeed = 5f;
    [SerializeField] private float panSpeed = 2f;
    [SerializeField] private float minDist = 0.5f;
    [SerializeField] private float maxDist = 5f;
    [SerializeField] private float eulerMin = 15f;
    [SerializeField] private float eulerMax = 75f;
    [SerializeField] private float panYMod = 1f;

    private float wDistance;
    private float cDistance;
    private Vector3 wEuler;
    private Vector3 cEuler;
    private Vector3 wOrigin;
    private Vector3 cOrigin;
    private bool isPanning = false;

    void Start()
    {
        cEuler = transform.localEulerAngles;
        wEuler = cEuler;

        if (orbitTarget != null)
        {
            wOrigin = orbitTarget.position;
            cOrigin = wOrigin;
        }
        else
        {
            wOrigin = new Vector3(0, panYMod, 0);//Vector3.zero;
            cOrigin = wOrigin;//Vector3.zero;
        }

        wDistance = Vector3.Distance(cOrigin, transform.position);

        wDistance = Mathf.Clamp(wDistance, minDist, maxDist);
        cDistance = wDistance;

        transform.position = cOrigin - transform.forward * cDistance;
    }

    void Update()
    {
        float _lerpTime = Time.deltaTime * 2f * lerpSpeed;

        wDistance -= Input.GetAxis("Mouse ScrollWheel") * Time.deltaTime * 5f * scrollSpeed;
        wDistance = Mathf.Clamp(wDistance, minDist, maxDist);
        cDistance = Mathf.Lerp(cDistance, wDistance, _lerpTime);

        if (Input.GetMouseButton(1))
        {
            wEuler.y += Input.GetAxis("Mouse X") * 3f;
            wEuler.x -= Input.GetAxis("Mouse Y") * 3f;

            wEuler.x = Mathf.Clamp(wEuler.x, eulerMin, eulerMax);

            wEuler.y %= 360f;
            if (wEuler.y < 0f)
            {
                wEuler.y += 360f;
            }
        }

        if (Input.GetMouseButton(2))
        {
            isPanning = true;

            float moveX = -Input.GetAxis("Mouse X") * panSpeed * (cDistance * 0.5f) * Time.deltaTime;
            float moveY = -Input.GetAxis("Mouse Y") * panSpeed * (cDistance * 0.5f) * Time.deltaTime;

            wOrigin += transform.right * moveX + transform.up * moveY;
        }

        wEuler.z = 0f;

        cEuler.x = Mathf.LerpAngle(cEuler.x, wEuler.x, _lerpTime);
        cEuler.y = Mathf.LerpAngle(cEuler.y, wEuler.y, _lerpTime);
        cEuler.z = Mathf.LerpAngle(cEuler.z, 0f, _lerpTime);

        transform.rotation = Quaternion.Euler(cEuler);

        if (!isPanning)
        {
            if (orbitTarget != null) wOrigin = orbitTarget.position;
            else wOrigin = new Vector3(0, panYMod, 0); //Vector3.zero;
        }

        cOrigin = Vector3.Lerp(cOrigin, wOrigin, _lerpTime);

        transform.position = cOrigin - transform.forward * cDistance;
    }
}