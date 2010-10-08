package org.arisgames.editor.components
{
import com.google.maps.LatLng;
import com.google.maps.Map3D;
import com.google.maps.MapAction;
import com.google.maps.MapEvent;
import com.google.maps.MapMouseEvent;
import com.google.maps.MapOptions;
import com.google.maps.MapType;
import com.google.maps.View;
import com.google.maps.controls.MapTypeControl;
import com.google.maps.controls.NavigationControl;
import com.google.maps.overlays.Marker;
import com.google.maps.overlays.MarkerOptions;
import mx.events.DynamicEvent;
import org.arisgames.editor.data.arisserver.Requirement;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;

public class RequirementsEditorMap extends Map3D
{
    [Bindable] public var requirement:Requirement;
    private var marker:Marker;
    private var mo:MarkerOptions;
    private var mapReady:Boolean = false;

    /**
     * Constructor
     */
    public function RequirementsEditorMap()
    {
        super();
        this.key = AppConstants.APPLICATION_ENVIRONMENT_GOOGLEMAP_KEY;
        mo = new MarkerOptions();
        mo.draggable = true;
        marker = new Marker(new LatLng(39.57182223734374, -95.9765625), mo);
        addEventListener(MapEvent.MAP_PREINITIALIZE, onMapPreinitialize);
        addEventListener(MapEvent.MAP_READY, onMapReady);
    }

    private function onMapPreinitialize(event:MapEvent):void
    {
        trace("onMapPreinstall being run.");
        var myMapOptions:MapOptions = new MapOptions;
        myMapOptions.zoom = 12;
        myMapOptions.viewMode = View.VIEWMODE_ORTHOGONAL;
        this.setInitOptions(myMapOptions);
    }

    private function onMapReady(event:MapEvent):void
    {
        trace("onMapReady is being called.");
        var latLng:LatLng = new LatLng(39.57182223734374, -95.9765625);
        setCenter(latLng, 4, MapType.NORMAL_MAP_TYPE);

        addControl(new NavigationControl());
        addControl(new MapTypeControl());

        // Disable double click zoom as map is using double click for marker placement
//        this.setDoubleClickMode(MapAction.ACTION_NOTHING);
        this.enableScrollWheelZoom();
        this.enableContinuousZoom();

        // Set Default Marker Location
        marker.addEventListener(MapMouseEvent.DRAG_END, handleDragEndEvent);
        addOverlay(marker);
        if (marker != null)
        {
            trace("marker is not null in onMapReady, so can do fly.  marker's latlon = '" + marker.getLatLng() + "'");
//            flyTo(marker.getLatLng(), 12, new Attitude(20, 30, 0), 3);
            setCenter(marker.getLatLng(), 12, MapType.NORMAL_MAP_TYPE);
        }
        mapReady = true;
    }

    public function getMarkerLatLon():LatLng
    {
        return marker.getLatLng();
    }

    public function setMarkerLatLon(value:LatLng):void
    {
        trace("Set markerLatLon called with value = '" + value + "'");
        if (value == null)
        {
            trace("value passed into setMarkerLatLon is null, so just returning with no action performed.");
            return;
        }
        marker.setLatLng(value);
        if (mapReady)
        {
            trace("marker is not null in setMarkerLocation, so can do fly.  marker's latlon = '" + marker.getLatLng() + "'");
//            flyTo(marker.getLatLng(), 12, new Attitude(20, 30, 0), 3);
            setCenter(marker.getLatLng(), 12, MapType.NORMAL_MAP_TYPE);
        }
    }

    public function handleDragEndEvent(event:MapMouseEvent):void
    {
        trace("RE Map Handle Drag End Event called; Requirement Id = '" + requirement.requirementId + "'");
        trace("Original Latitude: " + marker.getLatLng().lat() + "; Original Longitude: " + marker.getLatLng().lng());
        this.setMarkerLatLon(new LatLng(event.latLng.lat(), event.latLng.lng()));
        trace("Updated Latitude: " + marker.getLatLng().lat() + "; Updated Longitude: " + marker.getLatLng().lng());

        var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_SAVEREQUIREMENTDUETOMAPDATACHANGE);
        de.requirementId = requirement.requirementId;
        de.latitude = marker.getLatLng().lat();
        de.longitude = marker.getLatLng().lng();
        AppDynamicEventManager.getInstance().dispatchEvent(de);

        trace("Done with RE Map Drag event.");
    }
}
}